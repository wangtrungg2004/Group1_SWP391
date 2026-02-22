# Quiz Practicing System - Class Diagram (Simplified)

Class diagram đơn giản dựa trên Use Case Diagram.

## Mermaid Class Diagram

```mermaid
classDiagram
    class Customer {
        -String customerId
        -String name
        +viewRegistrations()
        +viewPracticesList()
        +createPractice()
        +takePracticeQuiz()
        +takeSimulationExam()
    }

    class Registration {
        -String registrationId
        -String customerId
        -Date registrationDate
    }

    class Practice {
        -String practiceId
        -String customerId
        -String title
        +peekAnswer()
    }

    class PracticeQuiz {
        -String quizId
        -String practiceId
        +peekAnswer()
        +answerQuestion()
        +markQuestion()
        +reviewProgress()
    }

    class SimulationExam {
        -String examId
        -String customerId
        -String title
        +answerQuestion()
        +markQuestion()
        +reviewProgress()
        +submitQuiz()
        +scoreExam()
    }

    class Question {
        -String questionId
        -String content
    }

    class Answer {
        -String answerId
        -String questionId
        -String customerId
        -boolean isCorrect
    }

    class QuizResult {
        -String resultId
        -String quizId
        -double score
        +calculateScore()
    }

    class Explanation {
        -String explanationId
        -String questionId
        -String content
    }

    Customer "1" --> "*" Registration
    Customer "1" --> "*" Practice
    Customer "1" --> "*" SimulationExam
    Customer "1" --> "*" Answer

    Practice "1" --> "*" PracticeQuiz
    PracticeQuiz "1" --> "*" Question
    SimulationExam "1" --> "*" Question

    Question "1" --> "*" Answer
    Question "1" --> "1" Explanation

    SimulationExam "1" --> "1" QuizResult
    QuizResult "1" --> "*" Answer
```

## Mô tả các lớp

- **Customer**: Người dùng hệ thống
- **Registration**: Đăng ký của khách hàng
- **Practice**: Phiên luyện tập
- **PracticeQuiz**: Quiz luyện tập (có thể peek answer)
- **SimulationExam**: Bài thi mô phỏng
- **Question**: Câu hỏi
- **Answer**: Câu trả lời
- **QuizResult**: Kết quả bài thi
- **Explanation**: Giải thích đáp án

## Ghi chú

- File PlantUML: `QuizPracticingSystem_ClassDiagram.puml`
- File Mermaid: Xem diagram trên
