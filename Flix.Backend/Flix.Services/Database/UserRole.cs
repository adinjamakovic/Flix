using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Flix.Services.Database
{
    public class UserRole
    {
        [Key]
        public int Id { get; set; }
        // User
        public int UserId { get; set; }
        [Required]
        [ForeignKey("UserId")]
        public User User { get; set; } = null!;
        // Role
        public int RoleId { get; set; }
        [Required]
        [ForeignKey("RoleId")]
        public Role Role { get; set; } = null!;
        public DateTime AssignedAt {get;set;} = DateTime.UtcNow;
    }
}
