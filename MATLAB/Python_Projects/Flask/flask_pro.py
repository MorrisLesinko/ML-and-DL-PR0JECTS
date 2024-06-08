from flask import Flask,redirect,url_for
"""

# Create WSGI Application
app = Flask(__name__)  # This Create WSGI Application

# Decorator carries the URL
@app.route('/')   # Help to create the numbers of URL 
def welcome():  # The binding function
    return 'Welcome to my Nation Kenya. Please Please visit to Maasai Mara'

# To create diff function the function name should be diff otherwise you will have errors

@app.route('/Members')
def Members():
    return 'Welcome to my Nation Kenya. Please Please visit to Maasai Mara and Also Mount Suswa'

if __name__ == '__main__':
    app.run(debug=True)  # Set debug to True or False

"""
#### HOW TO BUILD URL DYNAMICALLY
#### VARIABLE RULES AND URL BUILDING
app =Flask(__name__)
@app.route ('/')
def welcome():
    return 'WElcome to kenya the nation that is blessed of God'


@app.route ('/success/<int:score>')
def success(score):
    return 'The person has pass and the marks is '+str(score)



@app.route ('/fail/<int:score>')
def fail(score):
    return 'The person has pass and the marks is '+str(score)


# Result Checker
@app.route ('/results/<int:score>')
def results(marks):
    result =""
    if marks<50:
        result ="fail"
    else:
        result ="success"
    return redirect (url_for(result,score =marks))

if __name__ =='__main__':
    app.run(debug=True)
