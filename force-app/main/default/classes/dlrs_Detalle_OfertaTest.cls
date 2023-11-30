/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Detalle_OfertaTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Detalle_OfertaTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Detalle_Oferta__c());
    }
}