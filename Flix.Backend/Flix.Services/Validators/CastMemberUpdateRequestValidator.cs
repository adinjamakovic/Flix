using Flix.Model.Requests;
using FluentValidation;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Validators
{
    public class CastMemberUpdateRequestValidator : AbstractValidator<CastMemberUpdateRequest>
    {
        public CastMemberUpdateRequestValidator()
        {
            RuleFor(x => x.FirstName)
                .MaximumLength(100);

            RuleFor(x => x.LastName)
                .MaximumLength(100);
        }
    }
}
