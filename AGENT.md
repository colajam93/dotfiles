# Working on dotfiles

- Keep changes small and separate unrelated work into logical commits.
- Check the current branch and working tree before editing. Preserve existing
  changes; do not switch branches or rewrite history without a request.
- Target Bash and GNU coreutils. Keep configuration categories under `dotfiles/`
  and preserve the root `./install.sh` entry point and `bash install.sh` usage.
- Do not change default category selection or the installation method as part of
  unrelated work.
- Test public behavior rather than implementation details. For new behavior or
  bugs, reproduce the failure first, make the smallest fix, then refactor. Add
  passing characterization tests before refactoring existing behavior.
- Use test-only categories to verify the installer entry point. Do not duplicate
  the actual deployment file list in tests.
- Run `./tests/run.sh` and `./tests/lint.sh` in Docker and check `git diff --check`
  for installer or test changes. Use a temporary HOME for installation checks;
  do not apply configurations to the real home unless explicitly requested.
  Do not install test dependencies on the host with pacman.
- Keep tests in `tests/cases/` and reuse the Dockerfile from
  `vendor/dotfiles-lib/tests/docker/`. Keep ShellCheck settings in `.shellcheckrc`
  rather than adding configuration comments to installers.
- Treat `vendor/dotfiles-lib` as a Git subtree. Make shared-library changes in
  the dotfiles-lib repository and import them separately.
- Keep README minimal. Do not add work history or detailed configuration and
  symlink documentation unless explicitly requested.
- Keep private Git settings in `~/.config/git/private.conf`; track only its
  include directive, not the private file contents.
- Each commit message must be one English line, with no body or trailers.
  Prefix changes within `dotfiles/<category>/` with `<category>:`. Keep permission
  changes, test additions, and unrelated documentation changes in separate
  commits. Push only when explicitly requested.
