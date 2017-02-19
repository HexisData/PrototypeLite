CREATE TABLE [hq].[t_Recon_TestRight]
(
[RightKey1] [datetime] NOT NULL,
[RightKey2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RightCol1Bit] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RightCol2Int] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RightCol3Date] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RightCol4Decimal] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RightCol5Numeric] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RightCol6Nvarchar] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RightCol7NoReconcile] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RightCol8NoMapping] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [hq].[t_Recon_TestRight] ADD CONSTRAINT [PK_t_Test_ReconRight] PRIMARY KEY CLUSTERED  ([RightKey1], [RightKey2]) ON [PRIMARY]
GO
