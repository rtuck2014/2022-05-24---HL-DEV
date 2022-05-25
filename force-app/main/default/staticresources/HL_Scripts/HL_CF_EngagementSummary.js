$j = jQuery.noConflict();
$j(document).ready(function () {
    DocumentReady();
});
function DocumentReady() {
        //Remove Enter Functionality
        $j('.cfEngagementSummary input, select').keypress(function(e){
            if ( e.which == 13 ) // Enter key = keycode 13
                return false;
        });
        $j("[name$=piSubmit]").hide();
        if($j("[id$=summaryStatus]").val() != 'In Process'){
            $j(".cfEngagementSummary input").prop("readonly", true);
            $j(".cfEngagementSummary input[type='checkbox']").prop("disabled", true);
            $j(".cfEngagementSummary select").prop("disabled", true);
            $j("[id$=newCreditFacility]").hide();
            $j("[id$=btnApprove]").removeAttr('readonly');
            $j("[id$=btnReject]").removeAttr('readonly');
            $j(".relatedProcessHistory").show();
        }
       // else
        //    $j(".relatedProcessHistory").hide();

        $j("[id$=purchaseType]").change(function() {$j("[id$=purchaseTypeDependentLabel]").html($j(this).val() === 'Stock' ? 'Did Buyer Take 338(H)(10) Election?' : ' NOTE: Asset Sale - Set to Not Applicable'); });
        $j(".ui-dialog-content").dialog("destroy");
        $j("input.numeric-short, input.numeric-medium, input.numeric-long").keydown(function (event) {maskKeys(event);});
        $j("[id$=pbCarveoutCapitalizationDetails], [id$=pbCarveoutOwnershipDetails], [id$=pbCarveoutDueAuthorityDetails], [id$=pbCarveoutTaxesDetails], [id$=pbCarveoutDueOrganizationDetails], [id$=pbCarveoutBrokerFinderFeeDetails], [id$=pbCarveoutFraudDetails], [id$=pbCarveoutIntentionalBreachDetails]").hide();
        $j("[id$=imgCarveoutCapitalizationDetails]").click(function() {$j("[id$=pbCarveoutCapitalizationDetails]").show();});
        $j("[id$=imgCarveoutOwnershipDetails]").click(function() {$j("[id$=pbCarveoutOwnershipDetails]").show();});
        $j("[id$=imgCarveoutDueAuthorityDetails]").click(function() {$j("[id$=pbCarveoutDueAuthorityDetails]").show();});
        $j("[id$=imgCarveoutTaxesDetails]").click(function() {$j("[id$=pbCarveoutTaxesDetails]").show();});
        $j("[id$=imgCarveoutDueOrganizationDetails]").click(function() {$j("[id$=pbCarveoutDueOrganizationDetails]").show();});
        $j("[id$=imgCarveoutBrokerFinderFeeDetails]").click(function() {$j("[id$=pbCarveoutBrokerFinderFeeDetails]").show();});
        $j("[id$=imgCarveoutFraudDetails]").click(function() {$j("[id$=pbCarveoutFraudDetails]").show();});
        $j("[id$=imgCarveoutIntentionalBreachDetails]").click(function() {$j("[id$=pbCarveoutIntentionalBreachDetails]").show();});
        $j("[id$=pbCarveoutCapitalizationDetails] .rich-panelbar-header-act").click(function() {$j("[id$=pbCarveoutCapitalizationDetails]").hide();});
        $j("[id$=pbCarveoutOwnershipDetails] .rich-panelbar-header-act").click(function() {$j("[id$=pbCarveoutOwnershipDetails]").hide();});
        $j("[id$=pbCarveoutDueAuthorityDetails] .rich-panelbar-header-act").click(function() {$j("[id$=pbCarveoutDueAuthorityDetails]").hide();});
        $j("[id$=pbCarveoutTaxesDetails] .rich-panelbar-header-act").click(function() {$j("[id$=pbCarveoutTaxesDetails]").hide();});
        $j("[id$=pbCarveoutDueOrganizationDetails] .rich-panelbar-header-act").click(function() {$j("[id$=pbCarveoutDueOrganizationDetails]").hide();});
        $j("[id$=pbCarveoutBrokerFinderFeeDetails] .rich-panelbar-header-act").click(function() {$j("[id$=pbCarveoutBrokerFinderFeeDetails]").hide();});
        $j("[id$=pbCarveoutFraudDetails] .rich-panelbar-header-act").click(function() {$j("[id$=pbCarveoutFraudDetails]").hide();});
        $j("[id$=pbCarveoutIntentionalBreachDetails] .rich-panelbar-header-act").click(function() {$j("[id$=pbCarveoutIntentionalBreachDetails]").hide();});
        $j("[id$=imgPostClosingAdjustmentNote]").click(function() {$j(".ui-dialog-content").dialog("destroy"); $j("#postClosingAdjustmentNoteDialog").dialog({title:'Additional Details',modal: true, autoOpen: false, appendTo: $j("[id$=cfEngagementSummary]"), width: '820px'}).dialog('open'); return false;});
        $j("[id$=imgPreferredOrCommonStockNote]").click(function() {$j(".ui-dialog-content").dialog("destroy"); $j("#preferredOrCommonStockNoteDialog").dialog({title:'Additional Details',modal: true, autoOpen: false, appendTo: $j("[id$=cfEngagementSummary]"), width: '820px'}).dialog('open'); return false;});
        $j("[id$=imgOtherPaymentsNote]").click(function() {$j(".ui-dialog-content").dialog("destroy"); $j("#otherPaymentsNoteDialog").dialog({title:'Additional Details',modal: true, autoOpen: false, appendTo: $j("[id$=cfEngagementSummary]"), width: '820px'}).dialog('open'); return false;});
        $j("[id$=offerPrice], [id$=high52Week], [id$=low52Week], [id$=priorClose], [id$=weightedAvg30Day], [id$=weightedAvg60Day], [id$=weightedAvg90Day]").change(function() {calculatePurchasePricePremium();});
        $j("[id$=revolvingCreditFacility], [id$=termLoanA], [id$=termLoanB], [id$=termLoanC], [id$=delayedDrawTermLoan], [id$=seniorSubordinatedDebt], [id$=juniorSubordinatedDebt], [id$=unitrancheDebt], [id$=preferredEquity], [id$=commonEquity], [id$=sellerNotes], [id$=companyCashAR]").change(function() {calculateSourceOfFunds();});
        $j("[id$=purchasePrice], [id$=feesAndExpenses], [id$=closingCashBalance], [id$=proceedsToShareholders], [id$=debtPaidAtClosing], [id$=assumptionOfDebt], [id$=dealBonuses], [id$=useOther]").change(function() {calculateUseOfFunds();});
        $j("[id$=purchasePriceBase], [id$=workingCapitalAdjustments], [id$=postClosingAdjustments]").change(function() {calculatePurchasePrice();} );
        $j("[id$=considerationCash], [id$=considerationSellerNotes], [id$=considerationStock], [id$=considerationEarnout], [id$=considerationOtherPayments]").change(function() {calculateConsideration();} );
        $j("[id$=indemnityBasketSize], [id$=indemnityCapsSize], [id$=indemnityEscrowSize]").change(function() {calculateKeyContractPercents();});
        $j("[id$=transactionValueForFeeCalc],[id$=retainerFees], [id$=retainerFeesCreditable], [id$=completionOfCIM], [id$=completionOfCIMCreditable], [id$=firstRoundBid], [id$=firstRoundBidCreditable], [id$=secondRoundBid], [id$=secondRoundBidCreditable], [id$=loi], [id$=loiCreditable], [id$=signedAgreement], [id$=signedAgreementCreditable], [id$=otherFee01], [id$=otherFee01Creditable], [id$=otherFee02], [id$=otherFee02Creditable], [id$=transactionFee]").change(function() {calculateELDealDynamics();});
        $j("[id$=ratchet01Percent], [id$=ratchet01From], [id$=ratchet01To], [id$=ratchet02Percent], [id$=ratchet02From], [id$=ratchet02To], [id$=ratchet03Percent], [id$=ratchet03From], [id$=ratchet03To], [id$=ratchet04Percent], [id$=ratchet04From], [id$=ratchet04To],[id$=finalRatchetPercent],[id$=finalRatchetAmount]").change(function() {calculateELDealDynamics();});
        $j("[id$=addSellerContact]").click(function(){
            $j(".ui-dialog-content").dialog("destroy");
            var iframe_url = $j("[id$=lookupContactUrl]").html() + "?action=0&entity=" + $j("[id$=engagementId]").html();
            $j('<div></div>')
                   .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" />')
                   .dialog({
                        autoOpen: false,
                        title: 'Add Seller Contact',
                        resizable: true,
                        width: 600,
                        height: 600,
                        autoResize: false,
                        modal: true,
                        draggable: true,
                        close: function() {$j("[id$=refreshSellerTeam]").trigger('click');}
                }).dialog('open');
                return false;
        });
        $j("[id$=preTransactionSalary], [id$=preTransactionBonus]").change(function(){
            var preTransactionSalary = getNumericVal($j(this).parent().parent().find("[id$=preTransactionSalary]").val());
            var preTransactionBonus = getNumericVal($j(this).parent().parent().find("[id$=preTransactionBonus]").val());
            $j(this).parent().parent().find("[id$=preTransactionTotalComp]").html(formatNumber((preTransactionSalary + preTransactionBonus),2));
        });
        $j("[id$=equityFromTransaction], [id$=incentivesAtClose]").change(function(){
            var equityFromTransaction = getNumericVal($j(this).parent().parent().find("[id$=equityFromTransaction]").val());
            var incentivesAtClose = getNumericVal($j(this).parent().parent().find("[id$=incentivesAtClose]").val());
            $j(this).parent().parent().find("[id$=totalEmployeeProceedsAtClose]").html(formatNumber((equityFromTransaction + incentivesAtClose),2));
        });
        $j("[id$=postTransactionSalary], [id$=postTransactionBonus]").change(function(){
            var postTransactionSalary = getNumericVal($j(this).parent().parent().find("[id$=postTransactionSalary]").val());
            var postTransactionBonus = getNumericVal($j(this).parent().parent().find("[id$=postTransactionBonus]").val());
            $j(this).parent().parent().find("[id$=postTransactionTotalComp]").html(formatNumber((postTransactionSalary + postTransactionBonus),2));
        });
        $j("[id$=newCreditFacility]").click(function() {
            $j(".ui-dialog-content").dialog("destroy");
            var iframe_url = $j("[id$=debtStructureModifyUrl]").html() + "?action=1&eng=" + $j("[id$=engagementId]").html();
            $j('<div></div>')
            .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" />')
            .dialog({
                autoOpen: false,
                title: 'Add New Credit Facility',
                resizable: true,
                width: 1100,
                height: 700,
                autoResize: false,
                modal: true,
                draggable: true,
                show: {
                    effect: "fade",
                    duration: 500
                },
                hide: {
                    effect: "fade",
                    duration: 500
                },
                close: function() {$j("[id$=creditFacilityRefresh]").trigger('click');}
            }).dialog('open');
            return false;
    });
        $j("[id$=editCreditFacility]").click(function() {
            $j(".ui-dialog-content").dialog("destroy");
            var iframe_url = $j("[id$=debtStructureModifyUrl]").html() + '?action=1&eng=' + $j("[id$=engagementId]").html() + '&id=' + $j(this).siblings()[0].innerText;
            $j('<div></div>')
            .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="no" />')
            .dialog({
                autoOpen: false,
                title: 'Edit Credit Facility',
                resizable: true,
                width: 1100,
                height: 700,
                autoResize: false,
                modal: true,
                draggable: true,
                show: {
                    effect: "fade",
                    duration: 500
                },
                hide: {
                    effect: "fade",
                    duration: 500
                },
                close: function() {$j("[id$=creditFacilityRefresh]").trigger('click');}
            }).dialog('open');
            return false;
    });
    }

function calculatePurchasePricePremium(){
    var offerPrice = $j("[id$=offerPrice]").val();
    var high52Week = $j("[id$=high52Week]").val();
    var low52Week = $j("[id$=low52Week]").val();
    var priorClose = $j("[id$=priorClose]").val();
    var weightedAvg30Day = $j("[id$=weightedAvg30Day]").val();
    var weightedAvg60Day = $j("[id$=weightedAvg60Day]").val();
    var weightedAvg90Day = $j("[id$=weightedAvg90Day]").val();
    $j("[id$=high52WeekPercent]").html(isNaN(high52Week) || high52Week == 0 ? '0.0%' : ((offerPrice/high52Week - 1.0)*100.0).toFixed(1) + '%');
    $j("[id$=low52WeekPercent]").html(isNaN(low52Week) || low52Week == 0 ? '0.0%' : ((offerPrice/low52Week - 1.0)*100.0).toFixed(1) + '%');
    $j("[id$=priorClosePercent]").html(isNaN(priorClose) || priorClose == 0 ? '0.0%' : ((offerPrice/priorClose - 1.0)*100.0).toFixed(1) + '%');
    $j("[id$=weightedAvg30DayPercent]").html(isNaN(weightedAvg30Day) || weightedAvg30Day == 0 ? '0.0%' : ((offerPrice/weightedAvg30Day - 1.0)*100.0).toFixed(1) + '%');
    $j("[id$=weightedAvg60DayPercent]").html(isNaN(weightedAvg60Day) || weightedAvg60Day == 0 ? '0.0%' : ((offerPrice/weightedAvg60Day - 1.0)*100.0).toFixed(1) + '%');
    $j("[id$=weightedAvg90DayPercent]").html(isNaN(weightedAvg90Day) || weightedAvg90Day == 0 ? '0.0%' : ((offerPrice/weightedAvg90Day - 1.0)*100.0).toFixed(1) + '%');
}

function calculatePurchasePrice(){
    var totalPurchasePrice = $j("[id$=totalPurchasePrice]").html();
    var purchasePriceBase = getNumericVal($j("[id$=purchasePriceBase]").val());
    var workingCapitalAdjustments = getNumericVal($j("[id$=workingCapitalAdjustments]").val());
    var otherPostClosingAdjustments = getNumericVal($j("[id$=postClosingAdjustments]").val());
    var purchasePrice = purchasePriceBase + workingCapitalAdjustments + otherPostClosingAdjustments;
    $j("[id$=totalPurchasePrice]").html(purchasePrice.toFixed(2));
    if($j("[id$=transactionValueForFeeCalc]").val() === '' || $j("[id$=transactionValueForFeeCalc]").val() == totalPurchasePrice)
            $j("[id$=transactionValueForFeeCalc]").val(purchasePrice.toFixed(2));
    return purchasePrice;
}

function calculateTransactionValueForFeeCalculation(){
    calculatePurchasePrice;
    return $j("[id$=transactionValueForFeeCalc]").val();
}

function calculateKeyContractPercents(){
    var basketSize = getNumericVal($j("[id$=indemnityBasketSize]").val());
    var capsSize = getNumericVal($j("[id$=indemnityCapsSize]").val());
    var escrowSize = getNumericVal($j("[id$=indemnityEscrowSize]").val());
    var purchasePrice = calculatePurchasePrice();
    $j("[id$=indemnityBasketSizePercent]").html(basketSize == 0 ? '0.0%' : (basketSize / purchasePrice * 100.0).toFixed(2) + '%');
    $j("[id$=indemnityCapsSizePercent]").html(capsSize == 0 ? '0.0%' : (capsSize / purchasePrice * 100.0).toFixed(2) + '%');
    $j("[id$=indemnityEscrowSizePercent]").html(escrowSize == 0 ? '0.0%' : (escrowSize / purchasePrice * 100.0).toFixed(2) + '%');
}

function calculateConsideration(){
    var considerationCash = getNumericVal($j("[id$=considerationCash]").val());
    var considerationSellerNotes = getNumericVal($j("[id$=considerationSellerNotes]").val());
    var considerationStock = getNumericVal($j("[id$=considerationStock]").val());
    var considerationEarnout = getNumericVal($j("[id$=considerationEarnout]").val());
    var considerationOtherPayments = getNumericVal($j("[id$=considerationOtherPayments]").val());
    var totalConsiderations = considerationCash  + considerationSellerNotes + considerationStock + considerationEarnout + considerationOtherPayments;
    $j("[id$=considerationCashPercent]").html(considerationCash == 0 ? '0.0%' : (considerationCash/totalConsiderations*100.0).toFixed(1) + '%');
    $j("[id$=considerationSellerNotesPercent]").html(considerationSellerNotes == 0 ? '0.0%' : (considerationSellerNotes/totalConsiderations*100.0).toFixed(1) + '%');
    $j("[id$=considerationStockPercent]").html(considerationStock == 0 ? '0.0%' : (considerationStock/totalConsiderations*100.0).toFixed(1) + '%');
    $j("[id$=considerationEarnoutPercent]").html(considerationEarnout == 0 ? '0.0%' : (considerationEarnout/totalConsiderations*100.0).toFixed(1) + '%');
    $j("[id$=considerationOtherPaymentsPercent]").html(considerationOtherPayments == 0 ? '0.0%' : (considerationOtherPayments/totalConsiderations*100.0).toFixed(1) + '%');
    $j("[id$=totalConsideration]").html(totalConsiderations.toFixed(2));
    return totalConsiderations;
}

function calculateSourceOfFunds(){
    var revolvingCredit = getNumericVal($j("[id$=revolvingCreditFacility]").val());
    var termLoanA = getNumericVal($j("[id$=termLoanA]").val());
    var termLoanB = getNumericVal($j("[id$=termLoanB]").val());
    var termLoanC = getNumericVal($j("[id$=termLoanC]").val());
    var delayedDrawTermLoan = getNumericVal($j("[id$=delayedDrawTermLoan]").val());
    var seniorSubordinatedDebt = getNumericVal($j("[id$=seniorSubordinatedDebt]").val());
    var juniorSubordinatedDebt = getNumericVal($j("[id$=juniorSubordinatedDebt]").val());
    var unitrancheDebt = getNumericVal($j("[id$=unitrancheDebt]").val());
    var preferredEquity = getNumericVal($j("[id$=preferredEquity]").val());
    var commonEquity = getNumericVal($j("[id$=commonEquity]").val());
    var sellerNotes = getNumericVal($j("[id$=sellerNotes]").val());
    var companyCashAR = getNumericVal($j("[id$=companyCashAR]").val());
    var sourceTotal = revolvingCredit + termLoanA + termLoanB + termLoanC + delayedDrawTermLoan
                      + seniorSubordinatedDebt + juniorSubordinatedDebt + unitrancheDebt + preferredEquity + commonEquity
                      + sellerNotes + companyCashAR;

    $j("[id$=revolvingCreditFacilityPercent]").html(revolvingCredit == 0 ? '0.0%' : (revolvingCredit/sourceTotal * 100.0).toFixed(2) + '%');
    $j("[id$=termLoanAPercent]").html(termLoanA == 0 ? '0.0%' : (termLoanA/sourceTotal * 100.0).toFixed(2) + '%');
    $j("[id$=termLoanBPercent]").html(termLoanB == 0 ? '0.0%' : (termLoanB/sourceTotal * 100.0).toFixed(2) + '%');
    $j("[id$=termLoanCPercent]").html(termLoanC == 0 ? '0.0%' : (termLoanC/sourceTotal * 100.0).toFixed(2) + '%');
    $j("[id$=delayedDrawTermLoanPercent]").html(delayedDrawTermLoan == 0 ? '0.0%' : (delayedDrawTermLoan/sourceTotal * 100.0).toFixed(2) + '%');
    $j("[id$=seniorSubordinatedDebtPercent]").html(seniorSubordinatedDebt == 0 ? '0.0%' : (seniorSubordinatedDebt/sourceTotal * 100.0).toFixed(2) + '%');
    $j("[id$=juniorSubordinatedDebtPercent]").html(juniorSubordinatedDebt == 0 ? '0.0%' : (juniorSubordinatedDebt/sourceTotal * 100.0).toFixed(2) + '%');
    $j("[id$=unitrancheDebtPercent]").html(unitrancheDebt == 0 ? '0.0%' : (unitrancheDebt/sourceTotal * 100.0).toFixed(2) + '%');
    $j("[id$=preferredEquityPercent]").html(preferredEquity == 0 ? '0.0%' : (preferredEquity/sourceTotal * 100.0).toFixed(2) + '%');
    $j("[id$=commonEquityPercent]").html(commonEquity == 0 ? '0.0%' : (commonEquity/sourceTotal * 100.0).toFixed(2) + '%');
    $j("[id$=sellerNotesPercent]").html(sellerNotes == 0 ? '0.0%' : (sellerNotes/sourceTotal * 100.0).toFixed(2) + '%');
    $j("[id$=companyCashARPercent]").html(companyCashAR == 0 ? '0.0%' : (companyCashAR/sourceTotal * 100.0).toFixed(2) + '%');
    $j("[id$=sourceOfFundsTotal]").html(sourceTotal.toFixed(2));
}

function calculateUseOfFunds(){
    var purchasePrice = getNumericVal($j("[id$=purchasePrice]").val());
    var feesAndExpenses = getNumericVal($j("[id$=feesAndExpenses]").val());
    var closingCashBalance = getNumericVal($j("[id$=closingCashBalance]").val());
    var proceedsToShareholders = getNumericVal($j("[id$=proceedsToShareholders]").val());
    var debtPaidAtClosing = getNumericVal($j("[id$=debtPaidAtClosing]").val());
    var assumptionOfDebt = getNumericVal($j("[id$=assumptionOfDebt]").val());
    var dealBonuses = getNumericVal($j("[id$=dealBonuses]").val());
    var useOther = getNumericVal($j("[id$=useOther]").val());
    var useTotal = purchasePrice + feesAndExpenses + closingCashBalance + proceedsToShareholders + debtPaidAtClosing
                   + assumptionOfDebt + dealBonuses + useOther;

    $j("[id$=purchasePricePercent]").html(purchasePrice == 0 ? '0.0%' : (purchasePrice/useTotal * 100.0).toFixed(2) + '%');
    $j("[id$=feesAndExpensesPercent]").html(feesAndExpenses == 0 ? '0.0%' : (feesAndExpenses/useTotal * 100.0).toFixed(2) + '%');
    $j("[id$=closingCashBalancePercent]").html(closingCashBalance == 0 ? '0.0%' : (closingCashBalance/useTotal * 100.0).toFixed(2) + '%');
    $j("[id$=proceedsToShareholdersPercent]").html(proceedsToShareholders == 0 ? '0.0%' : (proceedsToShareholders/useTotal * 100.0).toFixed(2) + '%');
    $j("[id$=debtPaidAtClosingPercent]").html(debtPaidAtClosing == 0 ? '0.0%' : (debtPaidAtClosing/useTotal * 100.0).toFixed(2) + '%');
    $j("[id$=assumptionOfDebtPercent]").html(assumptionOfDebt == 0 ? '0.0%' : (assumptionOfDebt/useTotal * 100.0).toFixed(2) + '%');
    $j("[id$=dealBonusesPercent]").html(dealBonuses == 0 ? '0.0%' : (dealBonuses/useTotal * 100.0).toFixed(2) + '%');
    $j("[id$=useOtherPercent]").html(useOther == 0 ? '0.0%' : (useOther/useTotal * 100.0).toFixed(2) + '%');
    $j("[id$=useOfFundsTotal]").html(useTotal.toFixed(2));
}

function calculateELDealDynamics(){
    var retainerFees = getNumericVal($j("[id$=retainerFees]").val());
    var retainerFeesCreditable = $j("[id$=retainerFeesCreditable]").is(':checked');
    var completionOfCIM = getNumericVal($j("[id$=completionOfCIM]").val());
    var completionOfCIMCreditable =  $j("[id$=completionOfCIMCreditable]").is(':checked');
    var firstRoundBid = getNumericVal($j("[id$=firstRoundBid]").val());
    var firstRoundBidCreditable =  $j("[id$=firstRoundBidCreditable]").is(':checked');
    var secondRoundBid = getNumericVal($j("[id$=secondRoundBid]").val());
    var secondRoundBidCreditable =  $j("[id$=secondRoundBidCreditable]").is(':checked');
    var loi = getNumericVal($j("[id$=loi]").val());
    var loiCreditable =  $j("[id$=loiCreditable]").is(':checked');
    var signedAgreement = getNumericVal($j("[id$=signedAgreement]").val());
    var signedAgreementCreditable =  $j("[id$=signedAgreementCreditable]").is(':checked');
    var otherFee01 = getNumericVal($j("[id$=otherFee01]").val());
    var otherFee01Creditable =  $j("[id$=otherFee01Creditable]").is(':checked');
    var otherFee02 = getNumericVal($j("[id$=otherFee02]").val());
    var otherFee02Creditable =  $j("[id$=otherFee02Creditable]").is(':checked');
    var transactionFees = getNumericVal($j("[id$=transactionFee]").val());

    var totalFees = (!retainerFeesCreditable ? retainerFees : 0) + (!completionOfCIMCreditable ? completionOfCIM : 0) + (!firstRoundBidCreditable ? firstRoundBid : 0)
                       + (!secondRoundBidCreditable ? secondRoundBid : 0) + (!loiCreditable ? loi : 0) + (!signedAgreementCreditable ? signedAgreement : 0)
                       + (!otherFee01Creditable ? otherFee01 : 0) + (!otherFee02Creditable ? otherFee02 : 0) + transactionFees;
    var totalCredits = (retainerFeesCreditable ? retainerFees : 0) + (completionOfCIMCreditable ? completionOfCIM : 0) + (firstRoundBidCreditable ? firstRoundBid : 0)
                       + (secondRoundBidCreditable ? secondRoundBid : 0) + (loiCreditable ? loi : 0) + (signedAgreementCreditable ? signedAgreement : 0)
                       + (otherFee01Creditable ? otherFee01 : 0) + (otherFee02Creditable ? otherFee02 : 0);
    var purchasePrice = calculateTransactionValueForFeeCalculation() * 1000000.0;
    var ratchet01Percent = getNumericVal($j("[id$=ratchet01Percent]").val());
    var ratchet01FromAmt = getNumericVal($j("[id$=ratchet01From]").val());
    var ratchet01ToAmt = getNumericVal($j("[id$=ratchet01To]").val());
    var ratchet01Final = ratchet01ToAmt > 0 && purchasePrice > 0 ? purchasePrice >= ratchet01ToAmt ? (ratchet01ToAmt - ratchet01FromAmt) * ratchet01Percent/100.0 : (purchasePrice - ratchet01FromAmt) * ratchet01Percent/100.0 : 0;
    var ratchet02Percent = getNumericVal($j("[id$=ratchet02Percent]").val());
    var ratchet02FromAmt = getNumericVal($j("[id$=ratchet02From]").val());
    var ratchet02ToAmt = getNumericVal($j("[id$=ratchet02To]").val());
    var ratchet02Final = ratchet02ToAmt > 0 && purchasePrice > 0 ? purchasePrice >= ratchet02ToAmt ? (ratchet02ToAmt - ratchet02FromAmt) * ratchet02Percent/100.0 : (purchasePrice - ratchet02FromAmt) * ratchet02Percent/100.0 : 0;
    var ratchet03Percent = getNumericVal($j("[id$=ratchet03Percent]").val());
    var ratchet03FromAmt = getNumericVal($j("[id$=ratchet03From]").val());
    var ratchet03ToAmt = getNumericVal($j("[id$=ratchet03To]").val());
    var ratchet03Final = ratchet03ToAmt > 0 && purchasePrice > 0 ? purchasePrice >= ratchet03ToAmt ? (ratchet03ToAmt - ratchet03FromAmt) * ratchet03Percent/100.0 : (purchasePrice - ratchet03FromAmt) * ratchet03Percent/100.0 : 0;
    var ratchet04Percent = getNumericVal($j("[id$=ratchet04Percent]").val());
    var ratchet04FromAmt = getNumericVal($j("[id$=ratchet04From]").val());
    var ratchet04ToAmt = getNumericVal($j("[id$=ratchet04To]").val());
    var ratchet04Final = ratchet04ToAmt > 0 && purchasePrice > 0 ? purchasePrice >= ratchet04ToAmt ? (ratchet04ToAmt - ratchet04FromAmt) * ratchet04Percent/100.0 : (purchasePrice - ratchet04FromAmt) * ratchet04Percent/100.0 : 0;
    var finalRatchetPercent = getNumericVal($j("[id$=finalRatchetPercent]").val());
    var finalRatchetAmt = getNumericVal($j("[id$=finalRatchetAmount]").val());
    var finalRatchetFinal = finalRatchetAmt > 0 && purchasePrice > 0 && purchasePrice > finalRatchetAmt ? (purchasePrice - finalRatchetAmt) * finalRatchetPercent/100.0 : 0;

    if(ratchet01Final < 0)
        ratchet01Final = 0;
    if(ratchet02Final < 0)
        ratchet02Final = 0;
    if(ratchet03Final < 0)
        ratchet03Final = 0;
    if(ratchet04Final < 0)
        ratchet04Final = 0;
    if(finalRatchetFinal < 0)
        finalRatchetFinal = 0;

    $j("[id$=totalFees]").html(formatNumber(totalFees + ratchet01Final + ratchet02Final + ratchet03Final + ratchet04Final + finalRatchetFinal,2));
    $j("[id$=totalCredits]").html(formatNumber(totalCredits,2));
    $j("[id$=paymentOnClosing]").html(formatNumber((totalFees + ratchet01Final + ratchet02Final + ratchet03Final + ratchet04Final + finalRatchetFinal - totalCredits),2));
}

function getNumericVal(value)
{
   value = value.replace('$','').replace(',','').replace(',','');
   return (isNaN(value) || value == '' ? 0 : parseFloat(value));
}

function formatNumber(value, precision){
    return value.toFixed(precision).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}
