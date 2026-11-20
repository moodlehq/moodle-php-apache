import json
import os
from pathlib import Path
import subprocess
import tempfile
import textwrap
import unittest


ROOT = Path(__file__).resolve().parents[2]
SCRIPTS = ROOT / ".github" / "scripts"


class BuildScriptsTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / ".github").mkdir()
        (self.root / ".github" / "scripts").symlink_to(SCRIPTS, target_is_directory=True)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        for version in ("8.1-bookworm", "8.2-bookworm", "8.6-bookworm"):
            directory = self.root / "versions" / version
            directory.mkdir(parents=True)
            (directory / "Dockerfile").touch()
        self.env = os.environ.copy()
        self.env["PATH"] = f"{self.bin}{os.pathsep}{self.env['PATH']}"

    def run_script(self, name, *args):
        return subprocess.run(
            ["bash", str(SCRIPTS / name), *args],
            cwd=self.root,
            env=self.env,
            text=True,
            capture_output=True,
        )

    def command(self, name, body):
        path = self.bin / name
        path.write_text("#!/usr/bin/env bash\nset -eu\n" + body)
        path.chmod(0o755)

    def test_matrix_selection_and_unknown_version(self):
        result = self.run_script("build-matrix.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            [image["id"] for image in json.loads(result.stdout)],
            ["main", "8.1-bookworm", "8.2-bookworm", "8.6-bookworm"],
        )
        self.assertEqual(json.loads(result.stdout)[0]["context"], ".")
        result = self.run_script("build-matrix.sh", "8.6-bookworm, main")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual([image["id"] for image in json.loads(result.stdout)], ["main", "8.6-bookworm"])
        self.assertNotEqual(self.run_script("build-matrix.sh", "dev").returncode, 0)
        self.assertNotEqual(self.run_script("build-matrix.sh", "missing").returncode, 0)

    def test_duplicate_short_tags_are_rejected(self):
        directory = self.root / "versions" / "8.1-trixie"
        directory.mkdir()
        (directory / "Dockerfile").touch()
        self.assertNotEqual(self.run_script("build-matrix.sh").returncode, 0)

    def test_published_tags_for_main_and_version(self):
        workflow = (ROOT / ".github" / "workflows" / "test_buildx_and_publish.yml").read_text()
        step = workflow.split("      - name: Calculate image tags\n", 1)[1]
        script = textwrap.dedent(step.split("        run: |\n", 1)[1].split("\n      - uses:", 1)[0])
        self.env.update({
            "DOCKERHUB_OWNER": "moodlehq",
            "GH_OWNER": "moodlehq",
            "REPOSITORY": "moodle-php-apache",
            "GITHUB_OUTPUT": str(self.root / "output"),
        })
        for version, tags in (
            ("main", ["main"]),
            ("8.6-bookworm", ["8.6-bookworm", "8.6"]),
        ):
            self.env["VERSION"] = version
            Path(self.env["GITHUB_OUTPUT"]).write_text("")
            result = subprocess.run(["bash", "-c", script], env=self.env, text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            output = Path(self.env["GITHUB_OUTPUT"]).read_text().splitlines()
            self.assertEqual(output, [
                "tags<<EOF",
                *[f"moodlehq/moodle-php-apache:{tag}" for tag in tags],
                *[f"ghcr.io/moodlehq/moodle-php-apache:{tag}" for tag in tags],
                "EOF",
            ])

    def test_rebuild_selection_and_errors(self):
        self.command(
            "docker",
            """case "$3" in
    *:main) echo "8.6.0-dev 2026.1" ;;
    *:8.1-bookworm) echo "8.1.9 2026.2" ;;
    *:8.2-bookworm) echo "8.2.10 2026.1" ;;
    *:8.6-bookworm) echo "8.6.0-dev 2026.2" ;;
    *) exit 1 ;;
esac
""",
        )
        self.command(
            "curl",
            """if [[ "${FAIL_CURL:-}" == 1 ]]; then exit 1; fi
case "${*: -1}" in
    *timezonedb/stable.txt) echo '2026.2' ;;
    *hub.docker.com*)
        if [[ "${REGISTRY_FAILURE:-}" == 1 ]]; then echo 503
        elif [[ "${*: -1}" == *"/${MISSING_TAG:-__none__}" ]]; then echo 404
        else echo 200
        fi ;;
    *version=8.1) echo '{"version":"8.1.10"}' ;;
    *version=8.2) echo '{"version":"8.2.10"}' ;;
    *) exit 1 ;;
esac
""",
        )
        result = self.run_script("check-rebuilds.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "main,8.1-bookworm,8.2-bookworm")
        self.env["MISSING_TAG"] = "8.6-bookworm"
        result = self.run_script("check-rebuilds.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "main,8.1-bookworm,8.2-bookworm,8.6-bookworm")
        self.env["REGISTRY_FAILURE"] = "1"
        self.assertNotEqual(self.run_script("check-rebuilds.sh").returncode, 0)
        del self.env["REGISTRY_FAILURE"]
        self.env["FAIL_CURL"] = "1"
        self.assertNotEqual(self.run_script("check-rebuilds.sh").returncode, 0)

    def test_legacy_image_uses_legacy_fixtures_and_patch_check(self):
        self.env["DOCKER_LOG"] = str(self.root / "docker.log")
        self.command(
            "docker",
            """echo "$*" >> "$DOCKER_LOG"
case "$1" in
    run) echo container-id ;;
    port) echo 127.0.0.1:1234 ;;
esac
""",
        )
        self.command("curl", "exit 0\n")
        result = self.run_script("test-image.sh", str(ROOT / "versions" / "8.1-bookworm"), "image")
        self.assertEqual(result.returncode, 0, result.stderr)
        log = Path(self.env["DOCKER_LOG"]).read_text()
        self.assertIn("8.1-bookworm/tests/fixtures:/var/www/html", log)
        self.assertIn("php /var/www/html/check-php-patches.php", log)
        self.assertNotIn("/srv/moodle", log)
        self.assertIn("rm -f", log)


if __name__ == "__main__":
    unittest.main()
