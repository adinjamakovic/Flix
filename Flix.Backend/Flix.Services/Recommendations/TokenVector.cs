namespace Flix.Services.Recommendations
{
    // A sparse unit vector over attribute tokens. Unit length is what makes Dot a cosine, so a
    // movie described by a long cast list cannot outscore a sparsely described one on volume alone.
    public sealed class TokenVector
    {
        public static readonly TokenVector Empty = new([]);

        private readonly Dictionary<string, float> _weights;

        private TokenVector(Dictionary<string, float> weights)
        {
            _weights = weights;
        }

        public bool IsEmpty => _weights.Count == 0;

        public IReadOnlyDictionary<string, float> Weights => _weights;

        public static TokenVector Normalized(Dictionary<string, float> weights)
        {
            var norm = MathF.Sqrt(weights.Values.Sum(weight => weight * weight));

            if (norm <= 0)
                return Empty;

            foreach (var token in weights.Keys)
                weights[token] /= norm;

            return new TokenVector(weights);
        }

        public float Dot(TokenVector other)
        {
            var (smaller, larger) = _weights.Count <= other._weights.Count
                ? (_weights, other._weights)
                : (other._weights, _weights);

            var dot = 0f;

            foreach (var (token, weight) in smaller)
            {
                if (larger.TryGetValue(token, out var otherWeight))
                    dot += weight * otherWeight;
            }

            return dot;
        }
    }
}
