#### Using the Application

##### Data Visualization

In this tab you can explore the [SMS Spam Collection](http://archive.ics.uci.edu/ml/datasets/SMS+Spam+Collection) data set through a [word cloud](http://en.wikipedia.org/wiki/Tag_cloud) visualization. There are 3 parameters you can specify in the 'Data Explorer' pane:

* Data Set Sample Size: randomly selects a sample of the specified size from the data set.
* Minimum Word Frequency Across Sampled Data: specifies the lower threshold in number of times of appearance of a given word across the entire data set, in order for it to be considered in the word cloud.
* Maximum Number of Words Across Sampled Data: specifies the maximum number of words that will appear in the word cloud.

You can also explore the entire specified data sample through a [data table](http://datatables.net/) visualization, where you can search for a specific term across the sampled data and also sort the data by class or message text. This data table is shown in the 'Data Set Sample' pane.

By default, when you first click on the 'Data Visualization' tab, two word clouds (one for spam and other for non-spam messages) are shown in the right pane and built with the following parameters:

* Data Set Sample Size: 1,000 messages.
* Minimum Word Frequency Across Sampled Data: 5 times.
* Maximum Number of Words Across Sampled Data: 40 words.

Note: if your browser does not display the word clouds automatically when you enter the 'Data Visualization' tab, just click the 'Update Button'.

By clicking the 'Update' button, both word clouds and data table are updated according to the chosen parameters.

##### Model Building

In the 'Model Building Parameters' pane you control the parameters used for data preparation and model building, and build a [Naive Bayes](http://en.wikipedia.org/wiki/Naive_Bayes_classifier) classifier model.

You can pre-process the message text by choosing any combinations of the following text transformation tasks:

* Convert all text to lower-case.
* Remove all numbers in the text.
* Remove all [stop-words](http://en.wikipedia.org/wiki/Stop_words).
* Remove all punctuation characters.
* Remove additional white spaces from the text that may be left after removing numbers, stop-words, and punctuation characters.

For the model training and validation, you can specify the following options:

* Subset of the Data Set (%): sampled percentage of the entire data set to be considered, between 10% and 100%.
* Holdout Data for Model Validation (%): percentage of the sampled data to be considered for model validation, between 5% and 50%.
* Minimum Count of Terms in the Document-Term Matrix: minimum count of unique terms across the sampled data for model training, between 1 and 10, meaning that terms that occur less than that minimum count will not be considered in the [document-term matrix](http://en.wikipedia.org/wiki/Document-term_matrix).
* Laplace Smoothing for Naive Bayes: if set to 0, no [laplace smoothing](http://en.wikipedia.org/wiki/Additive_smoothing) will be used when training the Naive Bayes model. Otherwise, it will be set to the number specified (up to 5). Laplace smoothing helps by 'smoothing' the influence of terms that do not appear in the training data set when scoring new data.

By default, when you first click on the 'Model Building' Tab, a model is trained with the following parameters:

* For data transformation: no options selected
* For model training and validation:
 * Subset of the Data Set (%): 10
 * Holdout Data for Model Validation (%): 20
 * Minimum Count of Terms in the Document-Term Matrix: 5
 * Laplace Smoothing for Naive Bayes: 1

By clicking the 'Build Model' button, a new model is trained and validated according to the chosen parameters.

The output of the model building is then shown on the 'Model Validation Results' pane. It includes information about the training and validation sets used, as well as a [Confusion Matrix](http://en.wikipedia.org/wiki/Confusion_matrix) showing the scoring performance against the validation data set. Important model validation statistics, such as [Accuracy](http://en.wikipedia.org/wiki/Accuracy_and_precision), [Sensitivity](http://en.wikipedia.org/wiki/Sensitivity_and_specificity), and [Specificity](http://en.wikipedia.org/wiki/Sensitivity_and_specificity) are also shown.

##### Model Scoring

In this tab you have a chance to classify your own text by entering it in the text box and selecting its actual class (spam or non-spam), both in the 'Try your Own Data' pane. Your text message will be pre-processed according to the options selected in the 'Model Building' tab.

Then, by clicking the 'Classify' button, your message will be classified according to the last model built. The classification result is shown in the 'Scoring Results' pane.
