# Sentiment-analysis-app

This repository contain code necessary for the implementation of a fully functional web app to predict the sentiment of movie reviews using Amazon Web Services. 

There are two types of files:

1) A jupyter notebook file with the code used for: preprocessing data, building model, launching training jobs and deployment: ``SageMaker_Project_2.ipynb``

2) Print screens of the web app in service classifying sample reviews: ``review_sample_1, review_sample_2, review_sample_3``.

Below I show a summary of the project context and main outcomes:

The project aim to develop a web app that can receive a movie review and return a sentiment of the review for the user as ``Positive`` or ``Negative``. To build the app:

* A data base with 50,000 reviews were collected and preprocessed;
* 25.000 reviews were used to train a classifier with a recurrent neural network (LSTM) in Amazon SageMaker.
* An accuracy of 80% were obtained in the test set.
* The Pytorch model was deployed with SageMaker.
* An API Gateway was configured to interface with the web app.
* A lambda function was configured to interface with the API and trigger the deployed model through the endpoint.
