using Flix.Model.Requests;
using FluentValidation;
using System.Collections.Generic;
using System.Text;

namespace Flix.Services.Validators
{
    public class MovieRequestUpdateRequestValidator : AbstractValidator<MovieRequestUpdateRequest>
    {
        public MovieRequestUpdateRequestValidator()
        {
            Include(new MovieUpdateRequestValidator());
        }
    }
}
