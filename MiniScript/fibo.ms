function start(): void {
    var n1=0, n2=1, n3, i, num : number;

    writeString("Enter the number of elements: ");
    num = readNumber();

    printf("Fibonacci Series: ");
    writeString("\n");
    writeNumber(n1);
    writeString(" ");
    writeNumber(n2);
    writeString(" ");

    for(i=2 ; i<num; i=i+1){
        n3 = n1 + n2; 
        writeNumber(n3);
        writeString(" ");
        n1=n2;    
        n2=n3; 
    };
    
    writeString("\n");
}