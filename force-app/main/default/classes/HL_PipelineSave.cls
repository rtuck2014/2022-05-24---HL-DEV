public class HL_PipelineSave {
    public HL_PipelineSave() 
    {
    }
    
    public PageReference redirect()
    {
        string pagetype = ApexPages.currentPage().getParameters().get('pagetype');
        string show = ApexPages.currentPage().getParameters().get('show');
        string ig = ApexPages.currentPage().getParameters().get('ig');
        string st = ApexPages.currentPage().getParameters().get('st');
        string sta = ApexPages.currentPage().getParameters().get('sta');
        string off = ApexPages.currentPage().getParameters().get('off');
        string rt = ApexPages.currentPage().getParameters().get('rt');
        string sm = ApexPages.currentPage().getParameters().get('sm');
        string smid = ApexPages.currentPage().getParameters().get('smid');
        Pagereference pageref = new Pagereference('/apex/SL_PipelineManager?pagetype='+pagetype+'&show='+show+'&ig='+ig+'&st='+st+'&sta='+sta+'&off='+off+'&rt='+rt+'&sm='+sm+'&smid='+smid);
        return pageref; 
	}
}