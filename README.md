# Common Application Events

Library of Common Application Events

The HTTP Return codes are well known, well documented.  I say 200 or 404, you know what it is.  Each "hundreds" is a category that groups events.

The Library of Common Application Events uses the same approach, but for Event Ids:

- Event Ids
  - that are well documented, with links to related events, what to expect, etc.
  - that are intuitive categorized by class
    - 100s: low level
    - 200s: positive events
    - 300s: warnings that could interest IT
    - 400s: recoverable situations, the app should be able to continue, not the end of the world but IT needs to be aware
    - 500s: unrecoverable situations, the app can't deal with the problem and IT needs to take care of it.
    - 600s: failure, out of the app's control, the app might be able to continue to work but only partially.
    - 700s: ultimate shame for the development team - unhandled application exception
- Event messages: text content that is structured and predefined, with optionally mandatory parameters that give feedback to the person reading the log entry.
- Event log level: each Event Id is associated to a clear log level: Verbose, Information, Warning, Error, Critical

Best of all, each Event Id is wrapped in methods hiding the complexity on how to raise them.  Developers don't have to worry which Event Id number, log level, message text, etc.  They don't call Log.LogInformation(123, "this is the message I thought was right to say"), they call Log.Application.Starting(), and the method figures what Event Id, log level, message, etc.

Developers prefer spending their time adding features to their applications, than on non-functional requirements like logging.  When they do spend time logging, it has to be so easy that they don't even have to worry about things like log target, log level, event id, message content and format.

On the opposite of the equation, IT operations prefer looking at a dashboard showing that everything is going A-OK, than rushing like crazy trying to bring a critical application back online with upper management breathing fire in their necks.  The absolute best software is one that auto-heals itself and automagically and instantly adapt, we are borg.  Next inline is software that sends pre-incident warnings, and/or has a fall back plan/plan B in the event something out-of-its control occurs, we're actually there with telemetry, metrics and performance counters, and with dependency injection, application pattern with retry capabilities, a "something's wrong, but don't worry we have everything in control, continue what your merry way", etc.  Let's go to the far end of pendulum, an application that has no logging and spaghetti code - impossible for IT to troubleshoot.

## Dev meets Ops

The Common Logging Events makes it easy for developers to log events that are common to all if not most applications, while at the same time establishes a set of event Ids that learn, use and reuse, because they are documented, structured, categorized and complete.

### Numbers are for computers

Computers are great with numbers, but are bad a interpreting text.  The Library of Common Application Event defines a set of event Ids that are documented and follow a certain logic.  This numbering pattern makes it easy for IT Monitoring to program a monitoring tool to respond according to the ID of the event.

### Text is for humans

Humans are great at interpreting text, but are bad with numbers, so bad they need charts and graphs.  On the other hand, if the Event Ids follow a certain logic, humans can use intuition and deduction to quickly get a sense of urgency of any event.  

Developers (and end users by now) are happy when an HTTP return code is 200, raise an eyebrow with a 300, raise two eyebrows with a 404 and open their mouth for a 500.

Text content contains the details of the event.  404 + Page not found, 500 + Server Error + Invalid use of null.  So, the 500 includes the actual error, not just "Server error".

## Why - End user Experience

The worst User Experience is when a problem occurs in your application and the client has to inform your organization or IT Department about the problem, because the IT Operations has no clue your app is down.  The Monitoring team needs feedback from your app in order to respond quickly to incidents.

Your app fulfils a business requirement.  If your app stops, the end user can't do their job.  Many things can go wrong, things happen.  A good logging strategy helps IT Operations find the source of the problem and take necessary actions.  With bad logging or no logging at all, IT ops is blind as a bat, and troubleshooting is next to impossible.

Some incidents can be prevented, better apps sends telemetry and signals, leveraged by IT monitoring, giving IT the time to prepare for the worst or be pre-active.  This is being the scope of this Library of Common Application Events.

## Why - IT Monitoring

IT Monitoring is the team responsible for monitoring applications, servers, network, security, etc.  Monitoring a handful of applications can be done by a human but monitoring hundreds of different apps is another ball game.  What if, every app (or most apps) used the same event IDs, it would easier to set up of the monitoring tool, easier = less errors = better experience = good.

Standard, structured and documented event ids = easy to monitor.

Apps that uses the default EventId (0) for every event logged are impossible to monitor.

## Why - IT Support

If your application is suppose to be running and it suddenly stops, someone has to be alerted and look at it.  On the other hand, if the restart is planned, like for maintenance, no need to alert any one.

If you rely on humans to monitor event logs, than you don't have to worry.  On the other hand, if IT ops uses a monitoring application, IT will automate the monitoring application for your app, and respond in specific ways according to each event.  

Event Ids that are structured, following an intuitive scheme and that are well documented helps the support team troubleshoot your application = good.

Event message that is well defined, thorough, useful, and well documented helps the support team troubleshoot your application = good.

## Why - developers

An library that is well documented and easy to use is a library that developers will want to use.  At the same time, if that library abstracts a complexity that is secondary to the actual application, developers will prefer to use that library instead of reinventing the wheel, which will in turn make IT Ops's life much easier.

Everyone wins.
