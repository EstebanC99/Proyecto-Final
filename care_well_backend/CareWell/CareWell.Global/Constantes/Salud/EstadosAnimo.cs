namespace CareWell.Global.Constantes.Salud
{
    public abstract class EstadosAnimo
    {
        public const int MuyBien = (int)EstadosAnimoEnum.MuyBien;
        public const int Bien = (int)EstadosAnimoEnum.Bien;
        public const int Regular = (int)EstadosAnimoEnum.Regular;
        public const int Mal = (int)EstadosAnimoEnum.Mal;
        public const int MuyMal = (int)EstadosAnimoEnum.MuyMal;

        private enum EstadosAnimoEnum
        {
            MuyBien = 1,
            Bien = 2,
            Regular = 3,
            Mal = 4,
            MuyMal = 5
        }
    }
}
