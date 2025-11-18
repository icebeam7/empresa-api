using EmpresaApi.Models;
using Microsoft.EntityFrameworkCore;

namespace EmpresaApi.Data;

public class ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : DbContext(options)
{
    public DbSet<Contacto> Contactos => Set<Contacto>();
}
