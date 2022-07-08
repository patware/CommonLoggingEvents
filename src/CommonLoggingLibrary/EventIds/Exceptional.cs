﻿// Generated by a tool, do not change manually
// Tool: GenerateLibrary.ps1
// Generated Date: 

using Microsoft.Extensions.Logging;

namespace CommonLoggingLibrary.EventIds
{
  /// <summary>
  /// External, out of our control incidents, like timeouts/unavailable external systems, missing dependency that prevents the app from running.  Immediate intervention by an administrator is required.  Let&#39;s be clear, Exceptional doesn&#39;t mean so good it&#39;s exceptional, it&#39;s the opposite.
  /// </summary>
  public static class Exceptional
  {
    /// <summary>
    /// 601 The connection to the target system failed, timed out  Used in the raising of Event ID <see cref="Constants.EXTERNAL_CONNECTIONFAILEDTIMEOUT">601</see>.  To raise this Event, use method <see cref="External.ConnectionFailedTimeout"/>
    /// </summary>
    public static EventId External_ConnectionFailedTimeout => new(Constants.EXTERNAL_CONNECTIONFAILEDTIMEOUT, nameof(External.ExternalLoggingExtensions.External_ConnectionFailedTimeout));
    /// <summary>
    /// 602 Couldn&#39;t connect to target system, no response from target system.  Used in the raising of Event ID <see cref="Constants.EXTERNAL_CONNECTIONFAILEDTARGETSERVICEUNAVAILABLE">602</see>.  To raise this Event, use method <see cref="External.ConnectionFailedTargetServiceUnavailable"/>
    /// </summary>
    public static EventId External_ConnectionFailedTargetServiceUnavailable => new(Constants.EXTERNAL_CONNECTIONFAILEDTARGETSERVICEUNAVAILABLE, nameof(External.ExternalLoggingExtensions.External_ConnectionFailedTargetServiceUnavailable));
    /// <summary>
    /// 603 The version of the target resource doesn&#39;t match what was expected, the application can continue but using a plan B, and reduced capacity.  Used in the raising of Event ID <see cref="Constants.DEPENDENCY_VERSIONMISMATCHEDDEGRADEDMODE">603</see>.  To raise this Event, use method <see cref="Dependency.VersionMismatchedDegradedMode"/>
    /// </summary>
    /// <remarks>
    /// <para>It&#39;s typical in this situation that the application is put in {see 401} degraded mode.</para>
    /// </remarks>
    public static EventId Dependency_VersionMismatchedDegradedMode => new(Constants.DEPENDENCY_VERSIONMISMATCHEDDEGRADEDMODE, nameof(Dependency.DependencyLoggingExtensions.Dependency_VersionMismatchedDegradedMode));
    /// <summary>
    /// 604 Now this is bad.  An important resource isn&#39;t available, there&#39;s no plan B, and the application really can&#39;t continue.  This is a bad UX.  Used in the raising of Event ID <see cref="Constants.DEPENDENCY_VERSIONMISMATCHEDSHUTTINGDOWN">604</see>.  To raise this Event, use method <see cref="Dependency.VersionMismatchedShuttingDown"/>
    /// </summary>
    public static EventId Dependency_VersionMismatchedShuttingDown => new(Constants.DEPENDENCY_VERSIONMISMATCHEDSHUTTINGDOWN, nameof(Dependency.DependencyLoggingExtensions.Dependency_VersionMismatchedShuttingDown));
  }
}
