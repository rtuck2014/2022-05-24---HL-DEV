/**
 *  Server-side controller for HL_ReportSummaryWidget; fetches data from the designated Salesforce Report (located by developerName).
 *
 *  @author Graham MacRobie (graham.macrobie1129@hl.com)
 *  @date   February 2022
 */

global with sharing class HL_ReportSummaryWidgetController {
    global class ReportSummaryWidgetException extends Exception {
    }

	global class ReportColumn {
		@AuraEnabled
		global String name { get; set; }

        @AuraEnabled
        global String label { get; set; }

		@AuraEnabled
		global String dataType { get; set; }

		global ReportColumn(String name, String label, String dataType) {
			this.name = name;
            this.label = label;
			this.dataType = dataType;
		}

        global override String toString() {
            return name + ', ' + label + ', ' + dataType;
        }
	}

	global class ReportData {
		@AuraEnabled
		global Id reportId { get; set; }

		@AuraEnabled
		global String title { get; set; }

		@AuraEnabled
		global List<ReportColumn> columns { get; set; }

		@AuraEnabled
		global List<Map<String, Object>> rows { get; set; }

		global ReportData(Id reportId, String title) {
			this.reportId = reportId;
			this.title = title;

			columns = new List<ReportColumn>();
			rows = new List<Map<String, Object>>();
		}

		global ReportColumn addColumn(String name, String label, String dataType) {
            ReportColumn rc = new ReportColumn(name, label, dataType);

			columns.add(rc);

            return rc;
		}

		global void addRow(Map<String, Object> theRow) {
			rows.add(theRow);
		}
	}

	@AuraEnabled
	global static ReportData getReportData(String developerName, String recordIdField) {
		System.debug('developerName - ' + developerName);
		System.debug('recordIdField - ' + recordIdField);

		List<Report> rpts = [SELECT Id, DeveloperName FROM Report WHERE DeveloperName = :developerName LIMIT 1];

		if (rpts.size() == 0) {
            throw new ReportSummaryWidgetException('Report definition not found - ' + developerName);
		}

        Report rpt = rpts[0];

		Reports.ReportResults results = Reports.ReportManager.runReport(rpt.Id, true);

		Reports.ReportMetadata rm = results.getReportMetadata();

        Reports.ReportExtendedMetadata rem = results.getReportExtendedMetadata();

        Map<String, Reports.DetailColumn> columnMap = rem.getDetailColumnInfo();

		ReportData rptData = new ReportData(rpt.Id, rm.getName());

		for (String columnName : columnMap.keySet()) {
            Reports.DetailColumn dc = columnMap.get(columnName);

			ReportColumn rc = rptData.addColumn(dc.getName(), dc.getLabel(), dc.getDataType().name());  // TODO - need to lookup data type

			System.debug('column - ' + rc);
		}

		Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails) results.getFactMap().get('T!T');

		List<Reports.ReportDetailRow> rows = factDetails.getRows();

		for (Reports.ReportDetailRow row : rows) {
			Map<String, Object> newRow = new Map<String, Object>();

			List<Reports.ReportDataCell> cells = row.getDataCells();

			Integer i = 0;
			for (Reports.ReportDataCell cell : cells) {
                switch on rptData.columns[i].dataType {
                    when 'DATETIME_DATA' {
                        Datetime dt = (Datetime) cell.getValue();

        				newRow.put(rptData.columns[i].name, dt.getTime());
                    }

                    when else {
        				newRow.put(rptData.columns[i].name, cell.getLabel());
                    }
                }

				if (rptData.columns[i].name.equalsIgnoreCase(recordIdField)) {
					newRow.put('recordId', cell.getValue());
				}

				i++;
			}

			rptData.addRow(newRow);
		}

		return rptData;
	}
}