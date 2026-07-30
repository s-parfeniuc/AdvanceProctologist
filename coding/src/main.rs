fn max<'a>(a: &'a i32, b: &'a i32) -> &'a i32 {
    if a > b { a } else { b }
}

fn main() {
    let x = 5;
    let mut c: &i32;
    {
        let y = 10;
        c = max(&x, &y);
    }
    println!("The maximum is: {}", c);
}
