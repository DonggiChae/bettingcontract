# 코인 가격 예측 베팅 컨트랙트

정시마다 코인가격을 예측하여 베팅하는 프로젝트입니다.

정시마다 베팅이 시작되고 상금을 분배합니다.

정시부터 5분동안 베팅을 할 수있습니다. 

상승, 유지, 하락에 베팅할 수 있습니다. 

오라클을 사용하여 정시에 코인 가격을 받아옵니다.

받아온 가격을 토대로 베팅에서 이긴 사람들에게 상금을 분배합니다.

상금의 10프로는 개발자들에게 돌아가고 컨트랙트 트리거 비용과 개발자들의 개발 보상으로 사용됩니다.


## 오라클의 역할

매 정시마다 가격을 입력하여 상금을 분배하고 새로운 베팅을 시작하게 합니다.

5분 뒤에 베팅을 마감합니다. 


## 사용 스택

solidity
hardhat


## 컨트랙트 배포

```shell
//컴파일
npx hardhat compile
//배포
npx hardhat run scripts/deploy.ts --network klaytn //테스트넷
npx hardhat run scripts/deploy.ts --network klaytn_cypress //메인넷
```
컨트랙트를 컴파일 한 후에 디플로이 파일을 실행시켜 배포할 수 있습니다.


## 웹 페이지
https://github.com/DonggiChae/bettingpage
