using CommonLoggingLibrary.Application;

var loggerFactory = LoggerFactory.Create(builder => builder.AddSimpleConsole(configure => { configure.SingleLine = true; }));
var Log = loggerFactory.CreateLogger<Program>();

var startedInitializationAt = System.DateTime.UtcNow;
Log.Application_Starting(args);

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapRazorPages();

var finishedInitializationAt = System.DateTime.UtcNow;

Log.Application_InNormalMode();
Log.Application_Started((finishedInitializationAt - startedInitializationAt).TotalMilliseconds);

app.Run();
