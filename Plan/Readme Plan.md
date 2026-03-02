# Readme Plan  
Take a look at `ReciMe iOS Coding Challenge.pdf`. I have been working on this project which is a coding challenge for a job interview. I have completed the challenge and now need to produce the readme.   
  
First, ensure I have met all the requirements in the challenge pdf. (Get Codex to double check this)  
  
Then, only if I have met all the requirements, read what the PDF says about what needs to be in the readme.  
  
I want to make note of the following in the readme:  
* Claude Code used extensively, however I wanted to help make it clear what was me versus machine.  
    * First installed the `swiftui-expert` skills (honestly not too sure how much these were used)  
    * I also create the Plan folder to store the prompts and coding challenge.  
    * I use the Composable Architecture at work, so I’m a bit rusty on MVVM. So I included a mvvm.md file to help Claude understand MVVM for me.  
    * I used Superpowers plugin, with each plan file beginning a brainstorming session, through to implementation  
    * In the plan folder you can see `ReciMe iOS Coding Challenge Plan.md`, which was my initial prompt to Claude Code.  
        * In docs/plans/planning-prompts.md, this is a summary of the initial planning discussion  
    * After the initial implementation, I worked through consecutive updates which I provided as markdown files  
        * Update 1.md  
        * Update 2.md  
        * Update 3.md  
        * These have been provided so you can see the specific input I had in terms of UI, UX, implementation, coding quality and style, etc.  
    * A lot of effort was put into the filters UI/UX. It was quite a challenging problem to solve, how to make the filtering look good, be intuitive, and work well.  
    * I also made manual edits, changes with Claude, and changes with the new Xcode 26.3 coding agent (using Claude agent)  
        * New Xcode MCP was used extensively with Claude Code.  
  
Claude, make sure you read through our prior conversations to try and get an idea of key design decisions, assumptions, tradeoffs, limitations. You can also ask me if I remember any at the time. You can also try think of your own.  
  
Some known key design decisions:  
* Slight ReciMi branding colours  
* Native iOS look, with some colouring to add warmth.  
* Tried to follow native iOS principles as much as possible, such as using search tab.  
* Some Liquid Glass elements, such as filters.  
* Support for iPad  
* Consistent approach to filtering, improves UX  
* Instructions step by step mode  
* Card style  
  
Some known Assumptions & Tradeoffs  
* UI leans into native iOS look. This looks good to me, but to others they might prefer another look  
  
Some known Known Limitations  
* Sometimes the cards disappear when swiping back from detail view. Maybe related to LazyVGrid.  
* Filter expand/collapse animation can bit a little glitchy.  
* Dietary attributes are hardcoded. This could come from API as well, if likely to change.  
* Strings not setup for localisation (Not using stringsdict)  
  
The readme should be structured with primary headings matching what the challenge asks for. Subheadings are allowed. It should be very succinct and to the point.  
