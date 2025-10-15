# UART_FIFO
UART_protocall + FIFO을 이용하여 RTL설계

프로젝트 목표
1. UART Protocall의 이해
2. CDC환경에서의 metastable방지를 위한 FIFO사용
3. UART + FIFO를 활용하여 임베디드 시스템 구축(SR04 + DHT11 + Watch/StopWatch)
4. 동기식 FIFO가 아닌 비동기식 FIFO를 설계하여 READ 와 WRITE 동작을 동시 수행

설계 주의사항
1. Uart와 Button을 동시에 사용하기 때문에 multiple driven error 발생에 유의
2. DHT11의 경우 습도와 온도 두개를 표시할 수 있기에 SW를 이용하여 모드를 2개로 만들어 소수 정수 모두 표시
3. 비동기 FIFO의 경우 데이터가 메모리에 쌓이는지 확인이 불가능하기에 LED를 통하여 UART송신 시 LED를 모두 점등하여 확인
4. 비동기 FIFO는 Write Clock, Read Clock 2개의 Clock domain을 동시에 받기에 CDC를 유의할 것
