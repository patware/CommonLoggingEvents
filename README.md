# Common Application Events

Library of Common Application Events

Logging is not a sexy subject.  Developers roll their eyes when they're asked to "log" their app.  On the other side, logs entries are the only way IT can figure what happened or what's wrong with your app.

This library solves both problems:

- Developers: methods that wraps and abstracts the details of logging common app log entries
- IT: standard, documented, categorized, intuitive number scheme

The numbering, categorization and classification of the event IDs are based on the same principles that were used for the HTTP Return codes.  I say 404 Not found, you know what it is, right?  Each "hundreds" is a category that groups events.

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

## Developers

Without a Common Application Events, developers are faced with 4 things when logging an event:

1. When to log
1. What ID
1. What LogLevel (Information, Warning, Error, Critical)
1. What Message

They'll use something like:

```csharp
Log.LogWarning("The aplicaiton is starting");
Initialize();
```

What's wrong ?  The developer thought that an application starting was something wrong and defined it as a Warning, forgot to enter an EventID so it will default to 0, there's a typo in the message, the logging method doesn't display the app's arguments, and there's no clue that the application has finished initializing and is ready, therefor it's "started", which would be a nice touch for the IT looking at the logs.

The library abstracts these details.

```csharp
Log.ApplicationStarting(args);
Initialize();
Log.ApplicationStarted();
```

Developers prefer spending their time adding features to their applications, than on non-functional requirements like logging.  When they do spend time logging, it has to be so easy that they don't even have to worry about things like log target, log level, event id, message content and format.

On the opposite of the equation, IT operations prefer looking at a dashboard showing that everything is going A-OK, than rushing like crazy trying to bring a critical application back online with upper management breathing fire in their necks.  The absolute best software is one that auto-heals itself and automagically and instantly adapt, we are borg.  Next inline is software that sends pre-incident warnings, and/or has a fall back plan/plan B in the event something out-of-its control occurs, we're actually there with telemetry, metrics and performance counters, and with dependency injection, application pattern with retry capabilities, a "something's wrong, but don't worry we have everything in control, continue what your merry way", etc.  Let's go to the far end of pendulum, an application that has no logging and spaghetti code - impossible for IT to troubleshoot.

## IT Monitoring

IT Monitoring is the team responsible for monitoring applications, servers, network, security, etc.  Monitoring a handful of applications can be done by a human but monitoring hundreds of different apps is another ball game.  What if, every app (or most apps) used the same event IDs, it would easier to set up of the monitoring tool, easier = less errors = better experience = good.

Standard, structured and documented event ids = easy to monitor.

Apps that uses the default EventId (0) for every event logged are impossible to monitor.

## Why - IT Support

If your application is suppose to be running and it suddenly stops, someone has to be alerted and look at it.  On the other hand, if the restart is planned, like for maintenance, no need to alert any one.

If you rely on humans to monitor event logs, than you don't have to worry.  On the other hand, if IT ops uses a monitoring application, IT will automate the monitoring application for your app, and respond in specific ways according to each event.  

Event Ids that are structured, following an intuitive scheme and that are well documented helps the support team troubleshoot your application = good.

Event message that is well defined, thorough, useful, and well documented helps the support team troubleshoot your application = good.
