# Development Notes

## Repository Setup Considerations

### Subtree vs. Submodules

We chose **submodules** over subtrees for this repository, mainly because CrocoDash already uses submodules, and a flattened subtree structure would be cumbersome. The decision is not final—there's an opportunity to revisit if project needs change.

#### Potential Advantages of Subtree
- Easier to handle for less-advanced Git users.
- Allows users to make all changes (including sub-repos) and commit to their own use-case repo.
- Simpler workflow; likely to retain more users.
- Each repo remains more independent.

#### Submodule Drawbacks
- History mixing (uncertain if this matters for most use-cases).
- Easy to lose track of changes or introduce conflicts with upstream sub-repos (but use-case repos should be mostly read-only).
- More cumbersome to push changes upstream to sub-repos, but overall still less tricky than managing submodules within submodules.
    - We can help users with upstream push workflow if this gets adopted.

*Reasoning for current choice:*
- CrocoDash already has submodules.

---

## TODOs

These items are actionable and may be moved to GitHub Issues for better tracking and assignment in the future.

- [ ] Add instructions for submodules pull to `README.md`.
- [ ] Document in `README.md` that we are using submodules.
- [ ] Support flag selection for using SSH vs HTTPS Git URLs.
- [ ] Add environment variable support for version tags.
- [ ] Draft workflow for: "create fork from Bask-template" and install with `install.sh`
- [ ] Support for custom conda environment names.
- [ ] When stable enough, update CrocoCamp tag (rather than using hardcoded SHA).
- [ ] Add flag to install CESM and DART together with other packages.
    - [ ] If CESM/DART are not to be installed, prompt the user to provide the paths to their roots.
    - [ ] Provide an external script for users to update paths; the script should update the env variables loaded by conda packages.
- [ ] Prompt users for DART and CESM paths before starting installation.

---

## Environment Strategy Notes

- Building **four** separate conda environments:
    - CrocoDash
    - CrocoCamp
    - CUPiD-analysis
    - CUPiD-diagnostics

### Pros
- Each environment supports a distinct workflow.
- Avoids having to merge CUPiD's two environments.

### Cons
- Potential for package redundancy across environments.
- Increased risk of error due to complexity.
