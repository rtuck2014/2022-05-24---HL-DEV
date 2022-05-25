//This class is used to attempt to make uniform the way our custom modules handle search
public class HL_Search {
    //Base Search Term
    public String Base{get; set;}
    //Contains Search - Percent Preappended
    public String UseContains {get; set;}
    //Formatted For Like Operation
    public String SearchTerm{
        get{return UseContains + Base + '%';}
    }
    public String RevSearchTerm{
        get{return UseContains + Base.reverse() + '%';}
    }
    //Has Multiple Search Criteria (At Present we handle only Two Maximum)
    public Boolean HasMultiple{
        get{return !String.isBlank(Base) && Base.split(' ').size() > 1;}
    }
    //We are assuming only two search terms maximum (First and Last)
    public String Term01{
        get{return Base.split(' ')[0] + '%';}
    }
    public String Term02{
        get{return HasMultiple ? Base.split(' ')[Base.split(' ').size() - 1] + '%' : '';}
    }
    public HL_Search(string search, boolean contains){
        Base = String.escapeSingleQuotes(search.remove('*')).trim();
        UseContains = contains ? '%' : '';
    }
}