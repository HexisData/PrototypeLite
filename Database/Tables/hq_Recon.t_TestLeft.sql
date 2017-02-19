CREATE TABLE [hq_Recon].[t_TestLeft]
(
[LeftKey1] [datetime] NOT NULL,
[LeftKey2] [int] NOT NULL,
[LeftCol1Bit] [bit] NULL,
[LeftCol2Int] [int] NULL,
[LeftCol3Date] [datetime] NULL,
[LeftCol4Decimal] [decimal] (38, 8) NULL,
[LeftCol5Numeric] [numeric] (38, 8) NULL,
[LeftCol6Nvarchar] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeftCol7NoReconcile] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeftCol8NoMapping] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [hq_Recon].[t_TestLeft] ADD CONSTRAINT [PK_t_Test_ReconLeft] PRIMARY KEY CLUSTERED  ([LeftKey1], [LeftKey2]) ON [PRIMARY]
GO
