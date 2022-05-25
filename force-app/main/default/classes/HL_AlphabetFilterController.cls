public class HL_AlphabetFilterController {
    public Set<String> Alphabet {get; set;}
    public String Filter {get; set;}
    public HL_AlphabetFilterController(){
        this.Alphabet = new Set<String> {'All','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
    }
}