# Working on dotfiles-lib

- Keep changes small and separate unrelated work into logical commits.
- Check the current branch and working tree before editing. Preserve existing
  changes; do not switch branches or rewrite history without a request.
- Target Bash and GNU coreutils. Use `dfl_` for public functions and `_dfl_`
  for internal functions and globals.
- Preserve path arguments, including whitespace, glob characters, and newlines.
  Keep standard input available for interactive confirmation.
- Test public behavior rather than internal helpers. For new behavior or bugs,
  reproduce the failure first, make the smallest fix, then refactor. Add passing
  characterization tests before refactoring existing behavior.
- Run `./tests/run.sh` and `./tests/lint.sh` in Docker and check `git diff --check`.
  Do not install test dependencies on the host with pacman.
- Keep ShellCheck settings in `.shellcheckrc` when possible. Keep source tracking
  for this library; avoid broad warning suppression.
- Keep README minimal. Do not add work history, a Tests section, or detailed
  symlink documentation unless explicitly requested.
- Change the shared library here. Consumer subtree updates and home-directory
  migration are separate tasks; do not run consumers' installers on the real home
  as part of library validation.
- Commit when requested. Each commit message must be one English line, with no
  body or trailers. Push only when explicitly requested.
