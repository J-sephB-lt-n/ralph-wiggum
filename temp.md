features_list.json exists here in the schema I want: @agent_harness_app_template/features_list.json
Here's how I want the process to work:

1. Planning agent identifies which feature is going to be worked on in the current loop and sets "current_feature": "feature ID here" in features_list.json
2. Planning agent creates a plan for the feature. If this is a retry (after a failed review), then planning agent must make a new version of the plan (i.e. a new plan file), and plan file names follow a set naming scheme (so that it's obvious which plan is which to other agents) /docs/features/plans/<feature_id>/plan-<N>.md. If this is a retry (after a failed review) then the planning agent must read the latest code review. If this is a first attempt at a feature, the planning agent sets the feature status to IN_PROGRESS. If this is a retry, the status will be REVIEW_FAILED (set by the review agent) and the status should be left at REVIEW_FAILED.
3. Test agent writes tests based on the latest plan (the one which the planning agent just wrote). If this is a retry of the same feature (after a failed code review), then the test agent may choose to write additional tests (or not). If this is a retry (not first attempt at a feature), then the test agent should also read the latest code review document.
4. coding agent implements the plan until the tests for its feature pass. Then it sets the feature status to PENDING_REVIEW. If this is a retry feature, then the coding agent should read both the latest plan and latest code review before starting.
5. Before starting (after reading all of the relevant context docs and git logs), the review agent must run the full test suite and the application (try out some basic functionality of the application to see that it is working).
6. If this is a first review, the review agent checks the code against a predefined list of checks. Checks are assessed by severity. Any failed check at medium severity or higher result in a failed review. Findings under medium severity can just be cleaned up by the coding agent themselves, or just recorded in the review document and ignored if they are very low impact. If review is failed, review agent sets feature status to REVIEW_FAILED. The code review (whether review passes or fails) is written to docs/features/code_reviews/<feature_id>/review-<N>.md. The code review must be explicit about what must be changed in order to pass the code review on the next attempt. If this is not the first code review, then the code is only assessed against the list of explicit passing requirements in the previous code review (not the checklist) - if the code fails again, again the code review document must contain an explicit list of requirements for passing (which the NEXT code review will assess against). If a review passes, the review agent sets the status of the feature to COMPLETE. Only the review agent can mark a feature as COMPLETE.
   Other notes:

- There can only be one feature being worked on at a time. Agents can only move to a new feature once the current feature reaches COMPLETE status.
- Ralph wiggum loop automatically terminates by checking with jq that all features have status COMPLETE
- Agents don't have to write to dev_notes.md - only if they have something useful to add (e.g. they made a design decision).
- The basic 4-agent sequential dev loop should be very briefly explained to each agent (tell them which agent they are, which agent came before and which agent comes after).
- All agents are instructed to update the project docs if they have made changes which have caused the docs to diverge from the codebase.
- All agents commit their changes to git after making all of their changes.
  Does that make sense?
  If it does, then can you update @README.md to explain that this is how I want things to work?
  txt agent_harness_app_template/features_list.json
  txt README.md

  no more "fix" features. Please reread @agent_harness_app_template/features_list.json - I've added an "attempt_count" attribute. The review agent must increment this on a failed review. At the end of a loop (after the review agent), there can be deterministic jq check for early exit based on max feature retries.

2. Yes, correct. All termination checks are deterministic by parsing @agent_harness_app_template/features_list.json

# Running the Ralph Wiggum Loop

Prior to starting the agent loop, prepare the following documentation:

1. **`README.md`** - project overview.
2. **`features_list.json`** - ordered list of discrete features to implement.
3. (optional) **`docs/PRD.md`** - Product Requirements Document defining what to build and why.
4. (optional) **`docs/architecture_design.md`** - Architecture Design Document defining how to build.
5. (optional) Any other application documentation you like in `docs/` (all agents are instructed to read this before starting their task).

I highly recommend that you scaffold the folder layout (architecture) of your application, and document what each folder/file is for (and your architectural goals/patterns) in `README.md` (and/or `docs/architecture_design.md`) prior to starting the agent loop. Your coding agents are strongly instructed to adhere to your documentation, and a clearly defined (and documented) starting codebase architecture will hold back the floodgates of AI spaghetti code.

Then, start the agent loop using the following commands:
(These steps assume that lima-vm is already installed)

```bash
limactl create --name ralph --vm-type=qemu --containerd=system # default is ubuntu
limactl ls

cd ralph-wiggum/
cp -r agent_harness_app_template my-app-name

# optional: if you need your CA certificates in the VM ==================== #
mkdir my-app-name/.secret/ca-certificates
cp /usr/local/share/ca-certificates/* my-app-name/.secret/ca-certificates
# ========================================================================= #

limactl start ralph --mount-only ./my-app-name/:w  # only has read/write access to my-app-name/
limactl shell ralph

# start of commands run inside the VM ================================= #
sudo cp my-app-name/.secret/ca-certificates/* /usr/local/share/ca-certificates/ # only run if you copied in your CA certs earlier
sudo update-ca-certificates # only run if you copied in your CA certs earlier

bash my-app-name/.secret/environment_setup.sh cursor # if you want cursor-agent CLI
bash my-app-name/.secret/environment_setup.sh opencode # if you want opencode CLI
source ~/.bashrc # to get uv and opencode CLI commands to register

cd my-app-name
tree -a   # see the folder layout
git init
sudo mv .secret/cursor/cli-config.json ~/.cursor  # if using cursor
mkdir ~/.config/opencode
sudo mv .secret/opencode/opencode.json ~/.config/opencode # if using opencode
uv python install 3.14
uv init
export OPENAI_BASE_URL='...' # if using opencode
export OPENAI_API_KEY='...' # if using opencode

bash ralph_wiggum.sh \
  -l 20 \ # maximum number of agent loops (4 agents run per loop)
  -r 3 \ # if a code review for the same feature fails more than this many times, the loop exits
  -a cursor # one of ['cursor', 'opencode']
# exit codes of ralph_wiggum.sh:
#   0 = all features complete
#   1 = max review retries exceeded (early exit)
#   2 = maximum agent loops reached

exit
# end of commands run inside the VM =================================== #

limactl stop ralph
limactl stop --force ralph
limactl delete ralph
```
