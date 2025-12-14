# Release process

1. Update the version number in `hotkeys.ahk` (`CurrentVersion` variable).
2. Commit changes and tag the commit (format: `vX.Y.Z`).
3. Push the commit and tag to GitHub.
4. Wait for GitHub Actions to build the release artifacts and create a draft release.
5. Update the created draft release with release notes.
6. Publish the release on GitHub.
7. Update the version number in `version.txt`.
8. Commit and push the changes to the `main` branch.
