	@page 
	{ 
		size: A4 landscape; /* ISO/JIS A4 (210mm?297mm) */
		margin: 10mm;
		margin-bottom : 15mm;
		@bottom-right 
		{
			content: element(footer);
		}
	}
	.tableStyle   
	{
		width:100%;
		page-break-inside:avoid;
		-fs-table-paginate: paginate;
	}
	.tableStyle th
	{
		border-bottom: 0.5px #000000 solid;
	}