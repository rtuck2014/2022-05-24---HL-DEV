public class SL_QueryBuilder {
	public List<String> fields { get; set; }
	public String sObjectName { get; set; }
	private List<String> whereDefaultParts;
	private List<String> whereParts;
	private List<String> orderByParts;
	public Integer limitCount { get; set; }
	public Integer offsetCount { get; set; }

	public SL_QueryBuilder( String field, String sObjectName ) {
		this( new List<String>{ field }, sObjectName );
	}

	public SL_QueryBuilder( List<String> fields, String sObjectName ) {
		this.fields = fields;
		this.sObjectName = sObjectName;
		this.whereDefaultParts = new List<String>();
		this.whereParts = new List<String>();
		this.orderByParts = new List<String>();
		this.limitCount = 0;
		this.offsetCount = 0;
	}

	public String build() {
		return String.join( this.getQueryParts(), ' ' );
	}

	private List<String> getQueryParts() {
		List<String> result = new List<String>();

		result.add( 'SELECT' );
		result.add( String.join( new List<String>( new Set<String>( this.fields ) ), ',' ) );

		result.add( 'FROM' );
		result.add( this.sObjectName );

		if ( this.hasWhere() ) {
			result.add( 'WHERE' );
			result.add( String.join( this.getWhereAll(), ' AND ' ) );
		}
		if ( !this.orderByParts.isEmpty() ) {
			result.add( 'ORDER BY' );
			result.add( String.join( this.orderByParts, ',' ) );
		}
		if ( this.limitCount > 0 ) {
			result.add( 'LIMIT' );
			result.add( String.valueOf( this.limitCount ) );

			result.add( 'OFFSET' );
			result.add( String.valueOf( this.offsetCount ) );
		}

		return result;
	}

	public List<String> getWhereDefault() {
		return this.whereDefaultParts;
	}

	public List<String> getWhere() {
		return this.whereParts;
	}

	private List<String> getWhereAll() {
		List<String> result = new List<String>( this.whereDefaultParts );
		result.addAll( this.whereParts );
		return result;
	}

	private Boolean hasWhere() {
		return !this.whereDefaultParts.isEmpty() || !this.whereParts.isEmpty();
	}

	public void setWhere( List<String> whereRecords ) {
		this.whereParts.clear();
		this.whereParts.addAll( whereRecords );
	}

	public List<String> getOrderBy() {
		return this.orderByParts;
	}
}