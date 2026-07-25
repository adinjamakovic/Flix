using System.ComponentModel.DataAnnotations;

namespace Flix.Services.Database
{
    public class Role
    {
        [Key]
        public int Id { get; set; }
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;
        [MaxLength(250)]
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public bool IsActive {get; set;} = true;
        public ICollection<UserRole> UserRoles {get; set;} = new List<UserRole>();
    }
}
