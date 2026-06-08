namespace CareWell.Domain
{
    public abstract class BaseEntity
    {
        public virtual int ID { get; private set; }

        public override bool Equals(object? obj)
        {
            if (obj is not BaseEntity other)
                return false;

            if (ReferenceEquals(this, other))
                return true;

            if (GetType() != other.GetType())
                return false;

            if (this.ID == 0 || other.ID == 0)
                return false;

            return this.ID == other.ID;
        }

        public override int GetHashCode() => this.GetType().GetHashCode();
    }
}
