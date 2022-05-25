global with sharing class QuizHelper {

    public static final String QUESTION_TYPE_MULTI_SELECT = 'Multi Select';
    public static final String QUESTION_TYPE_TRUE_FALSE = 'True/False';
    public static final String QUESTION_TYPE_FREE_TEXT = 'Free Text';
    public static final String QUESTION_TYPE_SINGLE_SELECT = 'Single Select';
    public static final String QUESTION_TYPE_PAGE_BREAK = 'Page Break';
    public static final String QUESTION_TYPE_EMPTY = '';
    
    public static final String QUESTION_FREE_TEXT_TYPE_SHORT = 'Short Text';
    public static final String QUESTION_FREE_TEXT_TYPE_LONG = 'Long Text';
    
    public static final String ANSWER_CORRECT = 'Correct';
    public static final String ANSWER_INCORRECT = 'Incorrect';
    
    public static final String LABEL_CONGRATULATIONS_SCORE = 'Congratulations! You passed with a score of {0}%';
    public static final String LABEL_UNFORTUNATELY_SCORE = 'Unfortunately, your score of {0}% does not meet the {1} minimum passing score.';
    
    public static final String LABEL_CONGRATULATIONS = 'Thank You!';
    public static final String LABEL_QUIZ_MAX_ATTEMPTS_LIMIT_REACHED = 'The maximum number of attempts to pass Quiz has been reached';
    
    
    global class QuizLaunchModel extends MobileHelper.BaseViewModel{
        public String assignmentId;
        public QuizMetadata quizMetadata;
    }
    
    global class TemporaryQuizAnswers{
        public String quizId;
        public String assignmentId;
        public QuizQuestion question;
    }
    
    global class QuizSubmitResult extends MobileHelper.BaseViewModel{
        public Boolean canReview;
        public Boolean maxAttemptsLimitReached;
        public String message;
    }
    
    public static QuizSubmitResult submitQuiz(QuizLaunchModel quizLaunchModel){
        
        QuizSubmitResult quizSubmitResult = new QuizSubmitResult();
        if (!quizSubmitResult.isCFSUser){
            return quizSubmitResult;
        }
        
        if (quizLaunchModel == null || quizLaunchModel.assignmentId == null || String.isEmpty(quizLaunchModel.assignmentId) || quizLaunchModel.quizMetadata == null){
            throw new MobileHelper.MobileException('[submitQuiz] Wrong argument.');
        }
        
        List<lmscons__Transcript__c> transcripts = [SELECT Id FROM lmscons__Transcript__c WHERE lmscons__Trainee__c = :UserInfo.getUserId() LIMIT 1];
        if (transcripts.isEmpty()){
            throw new MobileHelper.MobileException('[submitQuiz] Not found transcript for trainee: ' + UserInfo.getUserId());        
        }
        
        lmscons__Transcript_Line__c quizAssignment = AssignmentsDataLoadHelper.getAssignment(quizLaunchModel.assignmentId);
        if (quizAssignment == null){
            throw new MobileHelper.MobileException('[submitQuiz] Not found assignment with id: ' + quizLaunchModel.assignmentId);            
        }
        
        quizSubmitResult.maxAttemptsLimitReached = !canLaunchQuiz(quizAssignment.lmscons__Quiz__r, quizAssignment.lmscons__Attempts__c);
        if (quizSubmitResult.maxAttemptsLimitReached){
            quizSubmitResult.message = LABEL_QUIZ_MAX_ATTEMPTS_LIMIT_REACHED;
            return quizSubmitResult;
        }
        
        List<lmscons__Quiz_Statistic__c> quizStatistics = getQuizStatistics(quizLaunchModel.quizMetadata.id, UserInfo.getUserId());
        Map<Id, lmscons__Quiz_Statistic__c> questionToStatistic = getQuestionToStatisticMap(quizStatistics);
        
        for(QuizQuestion quizQuestion : quizLaunchModel.quizMetadata.questions){
            lmscons__Quiz_Statistic__c statistic = questionToStatistic.get(quizQuestion.Id);
            
            if (statistic == null){
                statistic = new lmscons__Quiz_Statistic__c(
                        lmscons__Quiz__c = quizLaunchModel.quizMetadata.Id,
                        lmscons__Question__c = quizQuestion.id,
                        lmscons__Assignment__c = quizLaunchModel.assignmentId,
                        lmscons__Transcript__c = transcripts.get(0).Id
                );
                
                questionToStatistic.put(quizQuestion.id, statistic);
            }
            
            fillQuizStatistics(statistic, quizQuestion, true);
        }
        
        // get quiz with questions and correct answers.
        QuizMetadata quizMetadataWithCorrectInfo = getQuizMetadata(quizLaunchModel.quizMetadata.id);
        setAnswersFromStatistics(quizMetadataWithCorrectInfo, questionToStatistic.values());
        
        QuizCalculateResult quizCalculateResult = calculateQuiz(quizMetadataWithCorrectInfo);
        
        System.debug('quizCalculateResult = ' + quizCalculateResult);
        
        // fill quiz statistic with answers.
        for(lmscons__Quiz_Statistic__c quizStatistic : questionToStatistic.values()){
            Boolean correctAnswer = quizCalculateResult.questionCorrectAnswers.get(quizStatistic.lmscons__Question__c);
            quizStatistic.lmscons__Answer__c = correctAnswer == null ? null : correctAnswer ? ANSWER_CORRECT : ANSWER_INCORRECT; 
        }
        
        upsert questionToStatistic.values();
        
        setQuizAssignmentsProgressInfo(quizMetadataWithCorrectInfo, quizCalculateResult, quizAssignment);
        
        quizAssignment.lmscons__Attempts__c = quizAssignment.lmscons__Attempts__c == null ? 1 : quizAssignment.lmscons__Attempts__c + 1;
        
        // update all quiz asssignment for curren user.
        List<lmscons__Transcript_Line__c> quizAssignments = [SELECT id FROM lmscons__Transcript_Line__c WHERE lmscons__Transcript__r.lmscons__Trainee__c =:UserInfo.getUserId() AND lmscons__Quiz__c =: quizMetadataWithCorrectInfo.id];
        
        for(lmscons__Transcript_Line__c assignment : quizAssignments){
            if (quizMetadataWithCorrectInfo.scoredQuiz){
                assignment.lmscons__Score__c        = quizAssignment.lmscons__Score__c;
            }
            assignment.lmscons__Status__c           = quizAssignment.lmscons__Status__c;
            assignment.lmscons__Attempts__c         = quizAssignment.lmscons__Attempts__c;
            assignment.lmscons__Percent_Complete__c = quizAssignment.lmscons__Percent_Complete__c;
            assignment.lmscons__Completion_Date__c  = quizAssignment.lmscons__Status__c == MobileConstants.PASSED_STATUS ? system.now() : quizAssignment.lmscons__Completion_Date__c;
            assignment.lmscons__Completed_Date__c   = quizAssignment.lmscons__Status__c == MobileConstants.PASSED_STATUS ? date.today() : quizAssignment.lmscons__Completed_Date__c;
        }
        
        //quizAssignments.add(quizAssignment);
        update quizAssignments;
        
        quizSubmitResult.canReview = quizMetadataWithCorrectInfo.canReviewResults;
        quizSubmitResult.message = getQuizSubmitResultMessage(quizCalculateResult, quizMetadataWithCorrectInfo);
        
        return quizSubmitResult;
    }
    
    private static String getQuizSubmitResultMessage(QuizCalculateResult quizCalculateResult, QuizMetadata quizMetadata){
        
        if (!quizMetadata.scoredQuiz){
            return LABEL_CONGRATULATIONS;
        }
        
        Integer quizScore = quizCalculateResult.totalQuestions == 0 ? 0 : Math.round(100 * (quizCalculateResult.totalCorrectQuestions / Decimal.valueOf(quizCalculateResult.totalQuestions)));
        Integer passingScore = quizMetadata.passingScore == null ? null : Math.round(quizMetadata.passingScore);
        
        if (passingScore == null || (passingScore != null && quizScore >= passingScore) || quizCalculateResult.isOnlyQuestionsNotNeededAnswer){
            return String.format(LABEL_CONGRATULATIONS_SCORE, new String[] {String.valueOf(quizScore)});
        } else {
            return String.format(LABEL_UNFORTUNATELY_SCORE, new String[] { String.valueOf(quizScore), String.valueOf( quizMetadata.passingScore == null ? '0%' : quizMetadata.passingScore + '%')});
        }
    }
    
    private static void setQuizAssignmentsProgressInfo(QuizMetadata quizMetadata, QuizCalculateResult quizCalculateResult, lmscons__Transcript_Line__c quizAssignment){
        Integer quizScore = quizCalculateResult.totalQuestions == 0 ? 0 : Math.round(100 * (quizCalculateResult.totalCorrectQuestions / Decimal.valueOf(quizCalculateResult.totalQuestions)));

        Integer PreScore   = quizAssignment.lmscons__Score__c != null ? Integer.valueOf(quizAssignment.lmscons__Score__c) : 0;
        Integer PrePercent = quizAssignment.lmscons__Percent_Complete__c != null ? Integer.valueOf(quizAssignment.lmscons__Percent_Complete__c) : 0;
        Integer PassScore  = Integer.valueOf(quizMetadata.passingScore);

        system.debug('quizScore = ' + quizScore);
        system.debug('PreScore = ' + PreScore);
        system.debug('PrePercent = ' + PrePercent);
        system.debug('PassScore = ' + PassScore);
        system.debug('quizMetadata.scoredQuiz = ' + quizMetadata.scoredQuiz);

        if(quizMetadata.scoredQuiz){
            quizAssignment.lmscons__Score__c = (((PassScore != null) && (quizScore >= PassScore) && (quizScore >= PreScore)) ||
                                    ((PassScore != null) && (quizScore < PassScore) && (quizScore >= PreScore)) ||
                                    ((PassScore == null) && (quizScore >= PreScore))) ? String.valueOf(quizScore) : String.valueOf(PreScore);
        }
        
        system.debug('quizAssignment.lmscons__Score__c = ' + quizAssignment.lmscons__Score__c);

        if (PassScore == null) {
            quizAssignment.lmscons__Status__c = MobileConstants.PASSED_STATUS;
        }
        else {
            if ((quizScore >= PassScore)) {
                quizAssignment.lmscons__Status__c = MobileConstants.PASSED_STATUS;
            } else {
                if (quizAssignment.lmscons__Status__c != MobileConstants.PASSED_STATUS) {
                    quizAssignment.lmscons__Status__c = MobileConstants.FAILED_STATUS;
                }
            }
        }
        
        
        if (quizMetadata.show100IfFail && quizAssignment.lmscons__Status__c == MobileConstants.FAILED_STATUS) {
            quizAssignment.lmscons__Percent_Complete__c = 100;
        }
        else {
            if (PassScore == null) {
                quizAssignment.lmscons__Percent_Complete__c = 100;
            }
            else {
                if ((quizScore >= PassScore) || (PrePercent == 100)) {
                    quizAssignment.lmscons__Percent_Complete__c = 100;
                }
                else {
                    quizAssignment.lmscons__Percent_Complete__c = 0;
                }
            }
        }
        
        if (quizCalculateResult.isOnlyQuestionsNotNeededAnswer) {
            quizAssignment.lmscons__Score__c = null;
            quizAssignment.lmscons__Status__c = MobileConstants.PASSED_STATUS;
            quizAssignment.lmscons__Percent_Complete__c = 100;
        }

        if ((PassScore == null) && (quizScore == 0)) {
            quizAssignment.lmscons__Score__c = null;
            quizAssignment.lmscons__Status__c = MobileConstants.PASSED_STATUS;
            quizAssignment.lmscons__Percent_Complete__c = 100;
        }
        
    }
    
    class QuizCalculateResult{
        public Integer totalQuestions;
        public Integer totalCorrectQuestions;
        public Boolean isOnlyQuestionsNotNeededAnswer;
        Map<Id, Boolean> questionCorrectAnswers;
    }
    
    private static QuizCalculateResult calculateQuiz(QuizMetadata quizMetadata){
        
        QuizCalculateResult quizCalculateResult = new QuizCalculateResult();
        quizCalculateResult.questionCorrectAnswers = new Map<Id, Boolean>();
        
        quizCalculateResult.totalQuestions = 0;
        quizCalculateResult.totalCorrectQuestions = 0;
        quizCalculateResult.isOnlyQuestionsNotNeededAnswer = true;
        
        for(QuizQuestion question : quizMetadata.questions){
            if (!isQuestionNeedAnswer(question.questionType)){
                continue;
            }
            
            quizCalculateResult.isOnlyQuestionsNotNeededAnswer = false;
            
            quizCalculateResult.totalQuestions++;
            Set<String> correctAnswers = getCorrectAnswersIds(question.answers);
            Set<String> selectedAnswers = getAnswersIds(question.selectedAnswers);
            
            if (correctAnswers == null || correctAnswers.isEmpty()){
                throw new MobileHelper.MobileException('[calculateQuiz] Not found correct answers for question: ' + question);
            }
            
            Boolean correctAnswer = selectedAnswers != null && correctAnswers.size() == selectedAnswers.size() && correctAnswers.containsAll(selectedAnswers) && selectedAnswers.containsAll(correctAnswers);
            
            if (correctAnswer){
                quizCalculateResult.totalCorrectQuestions++;
            }
            
            quizCalculateResult.questionCorrectAnswers.put(question.id, correctAnswer);
        }
        
        return quizCalculateResult;
    }
    
    private static Set<String> getCorrectAnswersIds(List<QuestionAnswer> answers){
        Set<String> answersIds = new Set<String>();
        for(QuestionAnswer answer : answers){
            if (answer.correct){
                answersIds.add(answer.id);
            }
        }
        
        return answersIds;    
    }
    
    private static Set<String> getAnswersIds(List<QuestionAnswer> answers){
        Set<String> answersIds = new Set<String>();
        for(QuestionAnswer answer : answers){
            answersIds.add(answer.id);
        }
        
        return answersIds;
    }
    
    private static Boolean isQuestionNeedAnswer(String questionType){
        return QUESTION_TYPE_MULTI_SELECT.equals(questionType) || QUESTION_TYPE_SINGLE_SELECT.equals(questionType) || QUESTION_TYPE_TRUE_FALSE.equals(questionType);
    }
    
    public static void saveTemporaryQuizAnswers(TemporaryQuizAnswers temporaryQuizAnswers){
        
        if (temporaryQuizAnswers == null || temporaryQuizAnswers.quizId == null || 
            String.isEmpty(temporaryQuizAnswers.quizId) || 
            temporaryQuizAnswers.question == null || String.isEmpty(temporaryQuizAnswers.question.id)
            || temporaryQuizAnswers.assignmentId == null || String.isEmpty(temporaryQuizAnswers.assignmentId)){
        
            throw new MobileHelper.MobileException('[saveTemporaryAnswers] TemporaryQuizAnswers model error');        
        }
        
        List<lmscons__Transcript__c> transcripts = [SELECT Id FROM lmscons__Transcript__c WHERE lmscons__Trainee__c = :UserInfo.getUserId() LIMIT 1];
        if (transcripts.isEmpty()){
            throw new MobileHelper.MobileException('[saveTemporaryAnswers] Not found transcript for trainee: ' + UserInfo.getUserId());        
        }
        
        lmscons__Quiz_Statistic__c statistic = getQuestionStatistic(temporaryQuizAnswers.quizId, temporaryQuizAnswers.question.id, UserInfo.getUserId());   
        
        
        if (statistic == null){
            statistic = new lmscons__Quiz_Statistic__c(
                    lmscons__Quiz__c = temporaryQuizAnswers.quizId,
                    lmscons__Question__c = temporaryQuizAnswers.question.id,
                    lmscons__Assignment__c = temporaryQuizAnswers.assignmentId,
                    lmscons__Transcript__c = transcripts.get(0).Id
                );
        }
        
        fillQuizStatistics(statistic, temporaryQuizAnswers.question, false);
        
        upsert statistic;
    }
    
    private static void fillQuizStatistics(lmscons__Quiz_Statistic__c statistics, QuizQuestion question, Boolean fillAnswer){
        if (isQuestionNeedAnswer(question.questionType)){
            
            if (question.selectedAnswers == null || question.selectedAnswers.isEmpty()){
                statistics.lmscons__Temporary_Answer__c = '';
            } else {
                Map<String, String> answersMap = new Map<String, String>();
                for(QuestionAnswer questionAnswer : question.selectedAnswers){
                    answersMap.put(questionAnswer.id, questionAnswer.answer);    
                }                
                statistics.lmscons__Temporary_Answer__c = JSON.serialize(answersMap);
                
                if (fillAnswer){
                    statistics.lmscons__Long_Answer__c = JSON.serialize(answersMap.values());
                }
            }
            
        } else if (QUESTION_TYPE_FREE_TEXT.equals(question.questionType)){
            statistics.lmscons__Temporary_Answer__c = question.freeTextAnswer;
            if (fillAnswer){
                statistics.lmscons__Long_Answer__c = statistics.lmscons__Temporary_Answer__c;     
            }
        }   
    }
    
    public static QuizLaunchModel getQuizLaunchModel(MobileHelper.LearningObjectDetailsRequest learningObjectDetailsRequest){
        QuizLaunchModel quizLaunchModel = new QuizLaunchModel();
        
        if (!quizLaunchModel.isCFSUser){
            return quizLaunchModel;
        }
        
        quizLaunchModel.assignmentId = learningObjectDetailsRequest.assignmentId;
        quizLaunchModel.quizMetadata = getQuizMetadata(learningObjectDetailsRequest.id);
        processQuizMetadata(quizLaunchModel.quizMetadata);
        hideCorrectAnswers(quizLaunchModel.quizMetadata);
        
        List<lmscons__Quiz_Statistic__c> statistics = getQuizStatistics(quizLaunchModel.quizMetadata.Id, UserInfo.getUserId());
        setAnswersFromStatistics(quizLaunchModel.quizMetadata, statistics);
        
        return quizLaunchModel;
    }
    
    public static Boolean canLaunchQuiz(lmscons__Quiz__c quiz, Decimal attempts){
        Decimal maxAttempts = quiz.lmscons__Max_Attempts__c;
        return !(maxAttempts != null && attempts != null && attempts >= maxAttempts);
    }
    
    // gets data from DB, create and fills QuizMetadata object.
    public static QuizMetadata getQuizMetadata(String quizId){
        List<lmscons__Question__c> questions = getQuestions(quizId);
        
        if (questions == null || questions.isEmpty()){
            throw new MobileHelper.MobileException('[getQuizMetadata] Questions is null or empty');
        }
        
        QuizMetadata quizMetadata;
        
        for(lmscons__Question__c question : questions){
            
            Decimal questionOrder = null; 
            
            System.debug('question.lmscons__Quiz_Questions__r (' + question.lmscons__Quiz_Questions__r.size() + '): ' + question.lmscons__Quiz_Questions__r);
            
            // gets quiz order and quiz information from related lmscons__Quiz_Questions__r.
            for(lmscons__Quiz_Question__c quizQuestionItem : question.lmscons__Quiz_Questions__r){
                questionOrder = quizQuestionItem.lmscons__Order__c;
                
                if (quizMetadata == null){ // only one.
                    quizMetadata = new QuizMetadata(
                            quizQuestionItem.lmscons__Quiz__r.Id,
                            quizQuestionItem.lmscons__Quiz__r.Name,
                            quizQuestionItem.lmscons__Quiz__r.lmscons__Randomization__c,
                            quizQuestionItem.lmscons__Quiz__r.lmscons__Show_Score__c,
                            quizQuestionItem.lmscons__Quiz__r.lmscons__show_100_if_fail__c,
                            quizQuestionItem.lmscons__Quiz__r.lmscons__review_answers__c,
                            quizQuestionItem.lmscons__Quiz__r.lmscons__Maintain_correct_answers__c,
                            quizQuestionItem.lmscons__Quiz__r.lmscons__Passing_Score__c,
                            new List<QuizQuestion>()
                        );
                }        
                
                List<QuestionAnswer> questionAnswers = new List<QuestionAnswer>();
            
                // create new question.
                QuizQuestion newQuizQuestion = new QuizQuestion(
                        question.Id,
                        question.lmscons__Question__c,
                        null,
                        question.lmscons__Randomization__c,
                        QUESTION_FREE_TEXT_TYPE_LONG.equals(question.lmscons__Text_Type__c),
                        questionOrder,
                        question.lmscons__Type__c,
                        questionAnswers
                    );
                
                quizMetadata.questions.add(newQuizQuestion);
                
                System.debug('added question: ' + newQuizQuestion);
                
                // add answers to question.
                for(lmscons__Answer__c answer : question.lmscons__Answers__r){
                    questionAnswers.add(new QuestionAnswer(
                            answer.Id,
                            answer.lmscons__Answer__c,
                            answer.lmscons__Order__c,
                            answer.lmscons__Correct_Incorrect__c
                        ));  
                }
            }
        }
        
        return quizMetadata;   
    }
    
    // gets questions with related answers and quiz questions to get order and quiz.
    private static List<lmscons__Question__c> getQuestions(String quizId){
        return [SELECT 
                Id,
                Name,
                lmscons__Question__c,
                lmscons__Randomization__c,
                lmscons__Text_Type__c,
                lmscons__Type__c,
                (SELECT 
                    Id, lmscons__Order__c, lmscons__Quiz__c, lmscons__Quiz__r.Name, 
                    lmscons__Quiz__r.lmscons__Randomization__c, lmscons__Quiz__r.lmscons__review_answers__c, 
                    lmscons__Quiz__r.lmscons__Maintain_correct_answers__c,
                    lmscons__Quiz__r.lmscons__Show_Score__c,
                    lmscons__Quiz__r.lmscons__show_100_if_fail__c,
                    lmscons__Quiz__r.lmscons__Passing_Score__c
                FROM 
                    lmscons__Quiz_Questions__r),
                (SELECT Id, Name, lmscons__Answer__c, lmscons__Correct_Incorrect__c, lmscons__Free_Text__c, lmscons__Order__c  FROM lmscons__Answers__r)
            FROM 
                lmscons__Question__c 
            WHERE 
                id IN (SELECT lmscons__Question__c FROM lmscons__Quiz_Question__c WHERE lmscons__Quiz__c =: quizId)];
    }
    
    private static List<lmscons__Quiz_Statistic__c> getQuizStatistics(String quizId, String userId){
        return [SELECT 
                Id, Name, lmscons__Quiz__c, lmscons__Answer__c, lmscons__Assignment__c, lmscons__Learner__c, 
                lmscons__Long_Answer__c, lmscons__Question__c, lmscons__Temporary_Answer__c, lmscons__Transcript__c, lmscons__Type__c 
            FROM 
                lmscons__Quiz_Statistic__c
            WHERE 
                lmscons__Quiz__c = :quizId AND lmscons__Transcript__c IN (SELECT Id FROM lmscons__Transcript__c WHERE lmscons__Trainee__c =: userId)
            ];   
    }
    
    private static lmscons__Quiz_Statistic__c getQuestionStatistic(String quizId, String questionId, String userId){
        
        List<lmscons__Quiz_Statistic__c> statistics = [SELECT 
                Id, Name, lmscons__Quiz__c, lmscons__Answer__c, lmscons__Assignment__c, lmscons__Learner__c, 
                lmscons__Long_Answer__c, lmscons__Question__c, lmscons__Temporary_Answer__c, lmscons__Transcript__c, lmscons__Type__c 
            FROM 
                lmscons__Quiz_Statistic__c
            WHERE 
                lmscons__Quiz__c = :quizId AND lmscons__Question__c = :questionId AND lmscons__Transcript__c IN (SELECT Id FROM lmscons__Transcript__c WHERE lmscons__Trainee__c =: userId)
            LIMIT 1];   
            
        return statistics.isEmpty() ? null :  statistics.get(0);
    }
    
    private static void setAnswersFromStatistics(QuizMetadata quizMetadata, List<lmscons__Quiz_Statistic__c> statistics){
        
        if (!quizMetadata.maintainUsersAnswers){
            return;
        }
        
        Map<Id, lmscons__Quiz_Statistic__c> questionToStatistic = getQuestionToStatisticMap(statistics);
        
        for(QuizQuestion quizQuestion : quizMetadata.questions){
            lmscons__Quiz_Statistic__c statistic = questionToStatistic.get(quizQuestion.Id);
            if (statistic == null){
                continue;
            }
            
            if (QUESTION_TYPE_MULTI_SELECT.equals(quizQuestion.questionType) || QUESTION_TYPE_SINGLE_SELECT.equals(quizQuestion.questionType) || QUESTION_TYPE_TRUE_FALSE.equals(quizQuestion.questionType)){
                if (statistic.lmscons__Temporary_Answer__c != null && !String.isEmpty(statistic.lmscons__Temporary_Answer__c)){
                    Map<String, String> answerIdToAnswerText = (Map<String, String>)JSON.deserialize(statistic.lmscons__Temporary_Answer__c, Map<String, String>.class);          
                    for(String answerId : answerIdToAnswerText.keySet()){
                        for(QuestionAnswer questionAnswer : quizQuestion.answers){
                            if (answerId.equals(questionAnswer.Id)){
                                questionAnswer.checked = true;
                                quizQuestion.selectedAnswers.add(questionAnswer);
                            }
                        }
                    }
                }
            } else if (QUESTION_TYPE_FREE_TEXT.equals(quizQuestion.questionType)){
                quizQuestion.freeTextAnswer = statistic.lmscons__Temporary_Answer__c;
            }
        }
    }
    
    private static Map<Id, lmscons__Quiz_Statistic__c> getQuestionToStatisticMap(List<lmscons__Quiz_Statistic__c> statistics){
        Map<Id, lmscons__Quiz_Statistic__c> questionToStatistic = new Map<Id, lmscons__Quiz_Statistic__c>();
        for(lmscons__Quiz_Statistic__c statistic : statistics){
            questionToStatistic.put(statistic.lmscons__Question__c, statistic);
        }
        
        return questionToStatistic;
    }
    
    private static void hideCorrectAnswers(QuizMetadata quizMetadata){
        for(QuizQuestion quizQuestion : quizMetadata.questions){
            if (QUESTION_TYPE_FREE_TEXT.equals(quizQuestion.questionType)){
                if (quizQuestion.answers != null){
                    quizQuestion.answers.clear();   
                }
            } else{
                for(QuestionAnswer answer : quizQuestion.answers){
                    answer.correct = false;           
                }
            }
        }
    }
    
    
    // order questions, answers, set sequenceNumbers.
    private static void processQuizMetadata(QuizMetadata quizMetadata){
        
        List<QuizQuestion> questionsToOrder = new List<QuizQuestion>();
        List<QuizQuestion> pageBreaks = new List<QuizQuestion>();
        
        // remove page breaks.
        for(QuizQuestion quizQuestion : quizMetadata.questions){
            if (QUESTION_TYPE_PAGE_BREAK.equals(quizQuestion.questionType)){
                pageBreaks.add(quizQuestion);
            } else {
                questionsToOrder.add(quizQuestion);    
            }
        }
        
        System.debug('questionsToOrder: ' + questionsToOrder);
        System.debug('pageBreaks: ' + pageBreaks);
        
        if (QuizMetadata.rand){
            
            System.debug('questions random sort: ');
            
            // set random order.
            for(QuizQuestion quizQuestion : questionsToOrder){
                quizQuestion.order = getRandom(1, questionsToOrder.size());
            }
            
            System.debug('questionsToOrder: ' + questionsToOrder);
        }
        
        // order questions.
        questionsToOrder.sort();
        
        System.debug('after order');
        System.debug('questionsToOrder: ' + questionsToOrder);
        
        // order each question's answers.
        for(QuizQuestion quizQuestion : questionsToOrder){
            
            if (quizQuestion.answers == null || quizQuestion.answers.isEmpty()){
                continue;
            }
            
            if (quizQuestion.rand){
                for(QuestionAnswer answer : quizQuestion.answers){
                    answer.order = getRandom(1, quizQuestion.answers.size());
                }
            }
            
            quizQuestion.answers.sort();
        }
        
        
        // set sequence numbers.
        Integer counter = 1;
        for(QuizQuestion quizQuestion : questionsToOrder){
            if (quizQuestion.showNumber){
                quizQuestion.sequenceNumber = String.valueOf(counter);
                counter++;
            }
        }
        
        System.debug('after add numbers order');
        System.debug('questionsToOrder: ' + questionsToOrder);
        
        // sort page breaks to insert in valid position.
        pageBreaks.sort();
        
        System.debug('pageBreaks after sort');
        System.debug('pageBreaks: ' + pageBreaks);
        
        // set page breaks.
        for(QuizQuestion pageBreak : pageBreaks){
            if (pageBreak.order == null || pageBreak.order < 0){
                System.debug('ERRROR pageBreak.order is wrong: ' + pageBreak.order);
                continue; // need throw Exception.
            }
            
            system.debug('Page break position');
            system.debug(pageBreak.order);
            
            try{
                Integer pageBreakPosition = Math.round(pageBreak.order) - 1;
                if (pageBreakPosition >= questionsToOrder.size()){
                    questionsToOrder.add(pageBreak);    
                } else{
                    questionsToOrder.add(Math.round(pageBreak.order) - 1, pageBreak);    
                }
            } catch(Exception e){
                System.debug('ERRROR questionsToOrder.add');
                System.debug(e.getMessage());
                continue; // need throw Exception.
            } 
        }
        
        System.debug('result');
        System.debug('questionsToOrder: ' + questionsToOrder);
        
        quizMetadata.questions = questionsToOrder;
    }
    
    private static Decimal getRandom (Decimal lower, Decimal upper)
    {
        return Math.random() * (upper - lower) + lower;
    }

    // wrappers.
    global class QuizMetadata{
        
        public QuizMetadata(String id, String title, Boolean rand, Boolean scoredQuiz, Boolean show100IfFail, Boolean canReviewResults, Boolean maintainUsersAnswers, Decimal passingScore, List<QuizQuestion> questions){
            this.id = id;
            this.title = title;
            this.rand = rand;
            this.scoredQuiz = scoredQuiz;
            this.show100IfFail = show100IfFail;
            this.canReviewResults = canReviewResults;
            this.maintainUsersAnswers = maintainUsersAnswers;
            this.passingScore = passingScore;
            this.questions = questions;
        }
        
        public String id {get; set;}
        public String title {get; set;}
        public Boolean rand {get; set;}
        public Boolean scoredQuiz {get; set;}
        public Boolean show100IfFail {get; set;}
        public Boolean canReviewResults {get; set;}
        public Boolean maintainUsersAnswers {get; set;}
        public Decimal passingScore {get; set;}
        public List<QuizQuestion> questions {get; set;}
    }

    global class QuizQuestion implements Comparable {
        
        public QuizQuestion(
            String id,
            String title,
            String sequenceNumber,
            Boolean rand,
            Boolean multiLine,
            Decimal order,
            String questionType,
            List<QuestionAnswer> answers){
            
            this.id = id;
            this.title = title;
            this.rand = rand;
            this.multiLine = multiLine;
            this.order = order;
            this.questionType = questionType;
            this.answers = answers;
            
            this.selectedAnswers = new List<QuestionAnswer>();
            this.freeTextAnswer = '';
        }
        
        public Integer compareTo(Object compareTo) {
            
            QuizQuestion questionToCompare = (QuizQuestion)compareTo;
            
            if (this.order == null && questionToCompare.order == null){
                return 0;
            }
            
            if (this.order == null){
                return 1; 
            }
            
            if (questionToCompare.order == null){
                return -1; 
            }
            
            return Math.round(this.order - questionToCompare.order);
        }
        
        public String id {get; set;}
        public String title {get; set;}
        public String sequenceNumber {get; set;}
        public Boolean rand {get; set;}
        public Boolean multiLine {get; set;} 
        public Decimal order {get; set;}
        public String questionType {get; set { questionType = value; showNumber = !(value == null || value == QUESTION_TYPE_EMPTY || value == QUESTION_TYPE_PAGE_BREAK); }}
        
        public List<QuestionAnswer> answers {get; set;}
        public Boolean showNumber {get; private set;}
        
        public List<QuestionAnswer> selectedAnswers {get; set;}
        public String freeTextAnswer {get; set;}
    } 

    global class QuestionAnswer implements Comparable{
        
        public QuestionAnswer(
            String id,
            String answer,
            Decimal order,
            Boolean correct){
            
            this.id = id;
            this.answer = answer;
            this.order = order;
            this.correct = correct;
            this.checked = false;
        }
        
        public Integer compareTo(Object compareTo) {
            QuestionAnswer answerToCompare = (QuestionAnswer)compareTo;
            
            if (this.order == null && answerToCompare.order == null){
                return 0;
            }
            
            if (this.order == null){
                return 1; 
            }
            
            if (answerToCompare.order == null){
                return -1; 
            }
            
            return Math.round(this.order - answerToCompare.order);
        }
        
        public String id;
        public String answer;
        public Decimal order;
        public Boolean correct;
        
        public Boolean checked;
    }
}