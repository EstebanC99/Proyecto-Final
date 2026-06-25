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

        public override int GetHashCode() { 
            if (this.ID == default)
                return System.Runtime.CompilerServices.RuntimeHelpers.GetHashCode(this);

            return HashCode.Combine(GetType(), this.ID);
        }
    }
}
