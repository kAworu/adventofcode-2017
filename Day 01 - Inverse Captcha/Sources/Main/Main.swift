import InverseCaptcha

let puzzle = readLine()! // Acquire puzzle input from stdin.
let captcha = InverseCaptcha(puzzle)
print("The solution to the first captcha is \(captcha.neighbour_sum()),")
print("and the solution to the new captcha is \(captcha.halfway_around_sum()).")
