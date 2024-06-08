from flask import Flask, redirect, url_for, render_template, request

app = Flask(__name__)

"""
{%...%} for conditions,for loops

{{  }} expression to print output
{#....#}  This is for comments
"""

@app.route('/')
def welcome():
    return render_template('index.html')

@app.route('/success/<int:score>')
def success(score):
    return 'The person has passed and the marks are ' + str(score)

@app.route('/fail/<int:score>')
def fail(score):
    return 'The person has failed terribly and the marks are ' + str(score)

# Result Checker
@app.route('/results/<int:score>')
def results(score):
    result = ""
    if score < 50:
        result = "fail"
    else:
        result = "success"
    return redirect(url_for(result, score=score))

# RESULT CHECKER HTML PAGE
@app.route('/submit', methods=['POST', 'GET'])
def submit():
    if request.method == 'POST':
        math = float(request.form.get('Math', 0))  # Provide a default value of 0 if 'Math' key is missing
        science = float(request.form.get('Science', 0))
        c = float(request.form.get('C', 0))
        data_science = float(request.form.get('DataScience', 0))
        total_score = (math + science + c + data_science) / 4
        result = "success" if total_score >= 50 else "fail"
        return redirect(url_for(result, score=total_score))
    return render_template('submit.html')


if __name__ == '__main__':
    app.run(debug=True)
