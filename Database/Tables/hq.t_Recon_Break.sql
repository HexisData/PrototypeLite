CREATE TABLE [hq].[t_Recon_Break]
(
[RowKey] [nvarchar] (448) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MapId] [int] NOT NULL,
[LeftRowExists] [bit] NOT NULL,
[LeftValue] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RightRowExists] [bit] NOT NULL,
[RightValue] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [hq].[t_Recon_Break] ADD CONSTRAINT [PK_t_Core_ReconValue] PRIMARY KEY CLUSTERED  ([RowKey], [MapId]) ON [PRIMARY]
GO
