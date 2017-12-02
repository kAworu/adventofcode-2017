import InverseCaptcha

let puzzle = readLine()! // Acquire puzzle input from stdin.
let captcha = InverseCaptcha(puzzle)
print("The solution to the first captcha is \(captcha.next_solution()),")
print("and the solution to the new captcha is \(captcha.halfway_around_solution()).")
