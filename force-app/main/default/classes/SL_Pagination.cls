/**
 * \author Vladimir Dobrelya
 * \date Nov 20, 2014
 * \see https://silverline.jira.com/browse/HL-53
 */
public virtual class SL_Pagination {
	private Integer page, recordCount, itemsPerPage;

	public SL_Pagination() {
		this( 1, 1 );
	}

	public SL_Pagination( Integer recordCount, Integer itemsPerPage ) {
		this( 1,  recordCount, itemsPerPage );
	}

	public SL_Pagination( Integer page, Integer recordCount, Integer itemsPerPage ) {
		this.recordCount = recordCount;
		this.itemsPerPage = itemsPerPage;
		this.page = page;
	}

	public void next() {
		this.setPage( this.page + 1 );
	}

	public void previous() {
		this.setPage( this.page - 1 );
	}

	public Integer getPage() {
        return this.page;
    }

    public void setPage( String value ) {
        this.setPage( Integer.valueOf( value ) );
    }

    public virtual void setPage( Integer value ) {
    	this.page = value;
    	if ( this.page < 1 ) {
           	this.page = 1;
        } else if ( this.page > this.getLastPage() ) {
            this.page = this.getLastPage();
        }
    }

    public Integer getRecordCount() {
		return this.recordCount;
    }

    public virtual void setRecordCount( Integer value ) {
    	this.recordCount = value;
    }

    public Integer getItemsPerPage() {
		return this.itemsPerPage;
    }

    public virtual void setItemsPerPage( Integer value ) {
    	this.itemsPerPage = value;
    }

    public virtual Integer getLastPage() {
        if ( this.itemsPerPage > this.recordCount ) {
            return 1;
        }
        return (Integer)Math.ceil( (Decimal)this.recordCount / this.itemsPerPage );
    }

    public Boolean isLastPage {
        get {
            return this.page == this.getLastPage();
        }        
    }

    public Boolean hasNext {
    	get {
    		return this.page < this.getLastPage();
    	}        	
    }

    public Boolean hasPrevious {
    	get {
    		return this.page > 1;
    	}
    }
}