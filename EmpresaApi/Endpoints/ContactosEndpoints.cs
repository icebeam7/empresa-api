using EmpresaApi.Data;
using EmpresaApi.Models;
using Microsoft.EntityFrameworkCore;

namespace EmpresaApi.Endpoints;

public static class ContactosEndpoints
{
    public static IEndpointRouteBuilder MapContactos(this IEndpointRouteBuilder routes)
    {
        var group = routes.MapGroup("/contactos");

        // Operación: Agregar (POST /contactos/agregar)
        group.MapPost("/agregar", async (ContactoCreateRequest request, ApplicationDbContext db) =>
        {
            var contacto = new Contacto
            {
                Nombre = request.Nombre,
                Apellido = request.Apellido,
                Telefono = request.Telefono,
                Correo = request.Correo
            };

            db.Contactos.Add(contacto);
            await db.SaveChangesAsync();

            return Results.Created($"/contactos/{contacto.Id}", contacto);
        })
        .WithName("Contactos_Agregar")
        .WithSummary("Agrega un nuevo contacto")
        .WithTags("Contactos")
        .Produces<Contacto>(StatusCodes.Status201Created);

        return routes;
    }

    public record ContactoCreateRequest(string Nombre, string Apellido, string Telefono, string Correo);
}
