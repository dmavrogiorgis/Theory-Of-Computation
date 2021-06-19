function fibonacci(num: number) : number{
    if(num == 0)
        return 0;
    else if(num==1)
        return 1;
    else{
        return (fibonacci(num-1) + fibonacci(num-2)); 
    };
       
};

function start(): void {
    
    var num, i=0, c, fibo: number;

    writeString("Enter the number of elements: ");
    num = readNumber();

    writeString("\nFibonacci Series: ");

    for(c=1; c <= num;  c=c+1){
        fibo = fibonacci(i);

        writeNumber(fibo);
        writeString(" ");

        i = i + 1;
    };
    
    writeString("\n");
}