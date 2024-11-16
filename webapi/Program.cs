var builder = WebApplication.CreateBuilder(args);

// Adiciona serviços ao contêiner, incluindo o Swagger
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configuração do Swagger
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// app.UseHttpsRedirection();
app.UseAuthorization();

app.MapGet("/", (IEnumerable<EndpointDataSource> endpointSources) =>
{
    // "Hello World!" em JSON
    var message = new { Message = "Hello World!" };

    // Lista de endpoints
    var endpoints = endpointSources
        .SelectMany(source => source.Endpoints)
        .Where(endpoint => endpoint.Metadata.GetMetadata<HttpMethodMetadata>() != null)
        .Select(endpoint => new
        {
            Method = string.Join(", ", endpoint.Metadata.GetMetadata<HttpMethodMetadata>()?.HttpMethods ?? new List<string>()),
            Route = endpoint.DisplayName
        });

    return Results.Json(new { message, Endpoints = endpoints });
});

app.MapControllers();

app.Run();