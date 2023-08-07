# [Package Modules Working Group][wg-github]

This working group was there to investigate the possibility of using something
like the [NixOS module system][module-system] for Nixpkgs packages. See the
[discourse post][discourse-thread] for more info.

After a few months of meeting regularly, we conclude that it doesn't make sense to continue this working group in the same style.
Instead, the working group is being merged with the [Nixpkgs Architecture Team](https://nixos.org/community/teams/nixpkgs-architecture.html) to form mainly an idea sharing/discovery/reviewing/developing platform.

## Conclusion

The working group met every week, making sure that everybody has something assigned to do, all tracked in the issue tracker.
In particular we started out with small tasks to document the current problems, goals and use cases, such that everybody on the team could have a clear understanding of the issues.
Due to various reasons we haven't made a lot of progress on even these fairly small tasks, due to a combination of people being busy with other things and the tasks not being very interesting to work on.

And even if progress didn't stagnate, considerably more time than just a few hours a week is needed to really figure out good solutions.
And generally different people are not available to spend such amounts at the same time, meaning it would generally be one person working on this at a time.
This could be different if we had funding for members, but that's not the case here.

Because of this we decided to shut down this working group, but it will be merged it into the Nixpkgs Architecture Team to form a platform to share, discover, review and develop ideas.
Instead of writing down small tasks, the idea is to write down big tasks (probably in the [Nixpkgs Architecture Team issue tracker](https://github.com/nixpkgs-architecture/issues/issues)) that will take a considerable amount of time to do.
Anybody that can spend such time should indicate that in the issue to let others know it's being worked on, share their progress in the issue or on other channels, and get review from the team members.

This was discussed in the [meeting on 2023-07-28](./meetings/2023-07-28.md) and [on Matrix](https://matrix.to/#/!ujmUHefHRneAJeQbUs:matrix.org/$hXby0TiIaYw0J1G2FkS3Yym6PuPuhQNsUYkmu2GC-cI), where agreement was reached to do this.

## Meetings

Meeting notes were all committed to the [./meetings](./meetings) folder.
Occasional presentations are streamed and recorded to [this YouTube playlist](https://www.youtube.com/playlist?list=PLHG2N-mfvWT48ZGoUC5W6OMMdln0IsNrq) on the Nixpkgs Architecture Team channel.

## Matrix channel

This channel was used for chat discussions: https://matrix.to/#/#wg-pkgs-modules:matrix.org

## Milestones

- 1. [ ] Document and understand the [problems](./problems/) and use cases
- 2. [ ] Document and understand potential solution mechanisms
- 3. [ ] Evaluate and compare each mechanism and their feasibility
- 4. [ ] Develop proof-of-concept's for viable mechanisms
- 5. [ ] ...
- We reached agreement on this initial plan

[wg-github]: https://github.com/nixpkgs-architecture/pkgs-modules/
[wg-issues]: https://github.com/nixpkgs-architecture/pkgs-modules/issues
[wg-pulls]: https://github.com/nixpkgs-architecture/pkgs-modules/pulls
[wg-jitsi]: https://meet.jit.si/wg-pkgs-modules
[wg-pad]: https://pad.lassul.us/6k3p0UBvT-6z-w9Bsy_BIg#
[module-system]: https://nixos.org/manual/nixos/stable/index.html#sec-writing-modules
[discourse-thread]: https://discourse.nixos.org/t/working-group-member-search-module-system-for-packages/26574

## Members

Working group members were, in alphabetical order:

 - @DavHau
 - @edolstra
 - @growpotkin
 - @infinisil
 - @phaer

