using Microsoft.AspNetCore.Mvc;

[Route("api/[controller]")]
[ApiController]
public class ExampleController : ControllerBase
{
    // Primeiro endpoint: retorna uma mensagem simples
    [HttpGet("mensagem")]
    public IActionResult GetMensagem()
    {
        return Ok("GET string");
    }

    // Segundo endpoint: retorna uma lista de números
    [HttpGet("numeros")]
    public IActionResult GetNumeros()
    {
        var numeros = new[] { 1, 2, 3, 4, 5 };
        return Ok(numeros);
    }
}
