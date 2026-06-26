from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from dotenv import load_dotenv
import boto3, os, uuid

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv('SECRET_KEY', 'devkey123')

# -- Database Config --------------------------------------------------
DB_USER = os.getenv('DB_USER', 'root')
DB_PASS = os.getenv('DB_PASS', 'password')
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_NAME = os.getenv('DB_NAME', 'taskdb')

app.config['SQLALCHEMY_DATABASE_URI'] = (
    f'mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}'
)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# -- S3 Config ----------------------------------------------------------
S3_BUCKET = os.getenv('S3_BUCKET', '')
s3_client = boto3.client(
    's3',
    region_name=os.getenv('AWS_REGION', 'ap-south-1')
)

# -- Model ----------------------------------------------------------------
class Task(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    desc = db.Column(db.Text, nullable=True)
    status = db.Column(db.String(20), default='pending')
    file_key = db.Column(db.String(300), nullable=True)

# -- Routes ---------------------------------------------------------------
@app.route('/')
def index():
    tasks = Task.query.all()
    return render_template('index.html', tasks=tasks)

@app.route('/add', methods=['POST'])
def add():
    title = request.form.get('title')
    desc = request.form.get('desc')
    file = request.files.get('file')

    file_key = None

    if file and file.filename != '' and S3_BUCKET:
        file_key = f'uploads/{uuid.uuid4()}_{file.filename}'
        s3_client.upload_fileobj(file, S3_BUCKET, file_key)

    task = Task(title=title, desc=desc, file_key=file_key)
    db.session.add(task)
    db.session.commit()

    flash('Task added!', 'success')
    return redirect(url_for('index'))

@app.route('/update/<int:task_id>', methods=['POST'])
def update(task_id):
    task = Task.query.get_or_404(task_id)
    task.status = request.form.get('status', task.status)
    db.session.commit()
    return redirect(url_for('index'))

@app.route('/delete/<int:task_id>')
def delete(task_id):
    task = Task.query.get_or_404(task_id)
    db.session.delete(task)
    db.session.commit()
    return redirect(url_for('index'))

@app.route('/health')
def health():
    return {'status': 'ok'}, 200

if __name__ == '__main__':
    with app.app_context():
        db.create_all()

    app.run(host='0.0.0.0', port=5000, debug=False)