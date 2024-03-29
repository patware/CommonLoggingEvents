﻿// Generated by a tool, do not change manually
// Tool: GenerateLibrary.ps1
// Generated Date: 
using System;
using Microsoft.Extensions.Logging;

namespace CommonLoggingLibrary.Dependency
{
  /// <summary>
  /// Events an application would raise during the Dependency Injection phase.  Notice that there are 3 VersionMismatch events: VersionMismatch, VersionMismatchedDegradedMode and VersionMismatchedShuttingDown: VersionMismatch is for apps that don&#39;t have fall back plan but the app can continue with limited functionality, VersionMismatchedDegradedMode is for apps that can work with a fall back plan, like a local only implementation of a service until the external service is resumed, and VersionMismatchedShuttingDown is when the app can&#39;t continue at all.
  /// </summary>
  public static class DependencyLoggingExtensions
  {
    /// <summary>
    /// 504: Private static Declarator of <see cref="ResolutionFailed"/>
    /// </summary>
    private readonly static Action<ILogger, string, Exception?> _resolutionFailed = LoggerMessage.Define<string>(LogLevel.Warning, EventIds.Constants.DEPENDENCY_RESOLUTIONFAILED, "Failed to resolve dependency {friendlyName}");

    /// <summary>
    /// 504 - A resource wasn&#39;t found or loaded.
    /// Writes a message like "Failed to resolve dependency {friendlyName}"
    /// of <see cref="Microsoft.Extensions.Logging.LogLevel.Warning"/> and Event ID <see cref="EventIds.Constants.DEPENDENCY_RESOLUTIONFAILED">504</see>  (of event level/category <see cref="EventIds.UnrecoverableWarning"/>)
    /// </summary>
    public static void Dependency_ResolutionFailed(this ILogger logger, string friendlyName) => _resolutionFailed(logger, friendlyName, default!);

    /// <summary>
    /// 213: Private static Declarator of <see cref="VersionMatchesExpected"/>
    /// </summary>
    private readonly static Action<ILogger, string, string, string, Exception?> _versionMatchesExpected = LoggerMessage.Define<string, string, string>(LogLevel.Information, EventIds.Constants.DEPENDENCY_VERSIONMATCHESEXPECTED, "Good: {friendlyName} version {actualVersion} matches expected version {expectedVersion}");

    /// <summary>
    /// 213 - The version of the loaded resource matches the expected version.
    /// Writes a message like "Good: {friendlyName} version {actualVersion} matches expected version {expectedVersion}"
    /// of <see cref="Microsoft.Extensions.Logging.LogLevel.Information"/> and Event ID <see cref="EventIds.Constants.DEPENDENCY_VERSIONMATCHESEXPECTED">213</see>  (of event level/category <see cref="EventIds.OperationalInformation"/>)
    /// </summary>
    public static void Dependency_VersionMatchesExpected(this ILogger logger, string friendlyName, string actualVersion, string expectedVersion) => _versionMatchesExpected(logger, friendlyName, actualVersion, expectedVersion, default!);

    /// <summary>
    /// 304: Private static Declarator of <see cref="VersionMismatch"/>
    /// </summary>
    private readonly static Action<ILogger, string, string, string, Exception?> _versionMismatch = LoggerMessage.Define<string, string, string>(LogLevel.Warning, EventIds.Constants.DEPENDENCY_VERSIONMISMATCH, "Bad: {friendlyName} version {actualVersion} does not match expected version {expectedVersion}, some functionality might not work as expected.");

    /// <summary>
    /// 304 - The resource&#39;s version does not match the expected version.
    /// Writes a message like "Bad: {friendlyName} version {actualVersion} does not match expected version {expectedVersion}, some functionality might not work as expected."
    /// of <see cref="Microsoft.Extensions.Logging.LogLevel.Warning"/> and Event ID <see cref="EventIds.Constants.DEPENDENCY_VERSIONMISMATCH">304</see>  (of event level/category <see cref="EventIds.OperationalWarning"/>)
    /// </summary>
    public static void Dependency_VersionMismatch(this ILogger logger, string friendlyName, string actualVersion, string expectedVersion) => _versionMismatch(logger, friendlyName, actualVersion, expectedVersion, default!);

    /// <summary>
    /// 603: Private static Declarator of <see cref="VersionMismatchedDegradedMode"/>
    /// </summary>
    private readonly static Action<ILogger, string, string, string, string, string, Exception?> _versionMismatchedDegradedMode = LoggerMessage.Define<string, string, string, string, string>(LogLevel.Error, EventIds.Constants.DEPENDENCY_VERSIONMISMATCHEDDEGRADEDMODE, "Target {friendlyName} has wrong version {actualVersion}, expected version {expectedVersion}.  Using fallback {fallbackName} {fallbackVersion}, application will continue to work, but in degraded mode");

    /// <summary>
    /// 603 - The version of the target resource doesn&#39;t match what was expected, the application can continue but using a plan B, and reduced capacity.
    /// Writes a message like "Target {friendlyName} has wrong version {actualVersion}, expected version {expectedVersion}.  Using fallback {fallbackName} {fallbackVersion}, application will continue to work, but in degraded mode"
    /// of <see cref="Microsoft.Extensions.Logging.LogLevel.Error"/> and Event ID <see cref="EventIds.Constants.DEPENDENCY_VERSIONMISMATCHEDDEGRADEDMODE">603</see>  (of event level/category <see cref="EventIds.Exceptional"/>)
    /// </summary>
    /// <remarks>
    /// <para>It&#39;s typical in this situation that the application is put in {see 401} degraded mode.</para>
    /// </remarks>
    public static void Dependency_VersionMismatchedDegradedMode(this ILogger logger, string friendlyName, string actualVersion, string expectedVersion, string fallbackName, string fallbackVersion) => _versionMismatchedDegradedMode(logger, friendlyName, actualVersion, expectedVersion, fallbackName, fallbackVersion, default!);

    /// <summary>
    /// 115: Private static Declarator of <see cref="Loading"/>
    /// </summary>
    private readonly static Action<ILogger, Exception?> _loading = LoggerMessage.Define(LogLevel.Information, EventIds.Constants.DEPENDENCY_LOADING, "Resolving and loading dependencies");

    /// <summary>
    /// 115 - Good applications practice IoC/Inversion of Control by leveraging the power of a Dependency Injection framework.  This event marks the start of the Dependency Injection setup.
    /// Writes a message like "Resolving and loading dependencies"
    /// of <see cref="Microsoft.Extensions.Logging.LogLevel.Information"/> and Event ID <see cref="EventIds.Constants.DEPENDENCY_LOADING">115</see>  (of event level/category <see cref="EventIds.LowLevel"/>)
    /// </summary>
    public static void Dependency_Loading(this ILogger logger) => _loading(logger, default!);

    /// <summary>
    /// 116: Private static Declarator of <see cref="Resolved"/>
    /// </summary>
    private readonly static Action<ILogger, Exception?> _resolved = LoggerMessage.Define(LogLevel.Information, EventIds.Constants.DEPENDENCY_RESOLVED, "All dependencies are resolved");

    /// <summary>
    /// 116 - Alright, all dependencies have been resolved, loaded, configured, verified and validated.
    /// Writes a message like "All dependencies are resolved"
    /// of <see cref="Microsoft.Extensions.Logging.LogLevel.Information"/> and Event ID <see cref="EventIds.Constants.DEPENDENCY_RESOLVED">116</see>  (of event level/category <see cref="EventIds.LowLevel"/>)
    /// </summary>
    public static void Dependency_Resolved(this ILogger logger) => _resolved(logger, default!);

    /// <summary>
    /// 604: Private static Declarator of <see cref="VersionMismatchedShuttingDown"/>
    /// </summary>
    private readonly static Action<ILogger, string, string, string, Exception?> _versionMismatchedShuttingDown = LoggerMessage.Define<string, string, string>(LogLevel.Error, EventIds.Constants.DEPENDENCY_VERSIONMISMATCHEDSHUTTINGDOWN, "Target {friendlyName} has wrong version {actualVersion}, expected version {expectedVersion}.  Application can&#39;t continue.");

    /// <summary>
    /// 604 - Now this is bad.  An important resource isn&#39;t available, there&#39;s no plan B, and the application really can&#39;t continue.  This is a bad UX.
    /// Writes a message like "Target {friendlyName} has wrong version {actualVersion}, expected version {expectedVersion}.  Application can&#39;t continue."
    /// of <see cref="Microsoft.Extensions.Logging.LogLevel.Error"/> and Event ID <see cref="EventIds.Constants.DEPENDENCY_VERSIONMISMATCHEDSHUTTINGDOWN">604</see>  (of event level/category <see cref="EventIds.Exceptional"/>)
    /// </summary>
    public static void Dependency_VersionMismatchedShuttingDown(this ILogger logger, string friendlyName, string actualVersion, string expectedVersion) => _versionMismatchedShuttingDown(logger, friendlyName, actualVersion, expectedVersion, default!);

    /// <summary>
    /// 212: Private static Declarator of <see cref="ValidatingVersion"/>
    /// </summary>
    private readonly static Action<ILogger, string, Exception?> _validatingVersion = LoggerMessage.Define<string>(LogLevel.Information, EventIds.Constants.DEPENDENCY_VALIDATINGVERSION, "Validating {friendlyName} version");

    /// <summary>
    /// 212 - The Dependency Framework has loaded what was requested, but are they the right version?
    /// Writes a message like "Validating {friendlyName} version"
    /// of <see cref="Microsoft.Extensions.Logging.LogLevel.Information"/> and Event ID <see cref="EventIds.Constants.DEPENDENCY_VALIDATINGVERSION">212</see>  (of event level/category <see cref="EventIds.OperationalInformation"/>)
    /// </summary>
    public static void Dependency_ValidatingVersion(this ILogger logger, string friendlyName) => _validatingVersion(logger, friendlyName, default!);

  }
}

