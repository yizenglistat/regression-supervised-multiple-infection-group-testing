"
This function computes second-order derivative of risk probability matrix with respect to beta (and delta)

Input:
  
  X      : features matrix
  beta    : feature coefficients
  delta   : gumbel parameter
  alpha1  : spline coefficients
  alpha2  : spline coefficients
  ord     : order of spline
  niknots : number of interior knots
  wrt     : derivative with respect to which variable, 'both' or just 'beta'

Output:
  second derivative matrix for beta (and delta), dimension is N x (p x p) or N x (p+1 x p+1)
"
pp.dd<- function(X,beta,delta,alpha1,alpha2,ord,niknots,wrt='both'){
  # individual risk probability for disease type 1/type 2
  u1 <- g(X%*%beta,alpha1,ord,niknots)
  u2 <- g(X%*%beta,alpha2,ord,niknots)
  # first derivative of spline function (individual risk scores) for disease type 1/type 2    
  sp_d1 <- sp_d(X%*%beta,alpha1,ord,niknots)   
  sp_d2 <- sp_d(X%*%beta,alpha2,ord,niknots)
  # split X matrix into a list and each element is a row (subject) in the list
  X_list  <- lapply(seq_len(nrow(X)), function(idx) X[idx,])
  # a list of length = N, each element is a matrix of (p x p), i.e., X[i,]%*%t(X[i,])
  Xsq_11 <- lapply(X_list,function(x){(x%*%t(x))})
  # second derivative w.r.t beta 
  p11_ddbeta <- exp(-((-log(u1))^(1/delta)+(-log(u2))^(1/delta))^delta)*
        ((-log(u1))^(1/delta)+(-log(u2))^(1/delta))^(delta-2)*
        (
          ((-log(u1))^(1/delta)+(-log(u2))^(1/delta))^(delta)*
          ((-log(u1))^(1/delta-1)*(1-u1)*sp_d1+(-log(u2))^(1/delta-1)*(1-u2)*sp_d2)^2+
          ((delta-1)/delta)*((-log(u1))^(1/delta-1)*(1-u1)*sp_d1+(-log(u2))^(1/delta-1)*(1-u2)*sp_d2)^2+
          ((-log(u1))^(1/delta)+(-log(u2))^(1/delta))*
          (
            (1/delta-1)*(-log(u1))^(1/delta-2)*(1-u1)^2*sp_d1^2+
            (-log(u1))^(1/delta-1)*u1*(1-u1)*sp_d1^2-
            (-log(u1))^(1/delta-1)*(1-u1)*sp_dd1+
            (1/delta-1)*(-log(u2))^(1/delta-2)*(1-u2)^2*sp_d2^2+
            (-log(u2))^(1/delta-1)*u2*(1-u2)*sp_d2^2-
            (-log(u2))^(1/delta-1)*(1-u2)*sp_dd2
          )
        )
  p11_ddbeta <- listOps(p11_ddbeta,Xsq_11,"*")

  
  
  if(dim == p1+p2+3){
    p11.dd <- mapply(function(d11,d12,d13,d22,d23,d33){rbind(cbind(d11,d12,d13),cbind(t(d12),d22,d23),cbind(t(d13),t(d23),d33))},
                     d11,d12,d13,d22,d23,d33,SIMPLIFY = FALSE)
    p01.dd <- listOps((1-2*u2)*u2*(1-u2),xxt22,"*")
    p01.dd <- lapply(p01.dd,function(x){rbind(matrix(0,p1+1,p1+p2+3),cbind(matrix(0,p2+1,p1+1),x,matrix(0,p2+1,1)),matrix(0,1,p1+p2+3))})
    p01.dd <- listOps(p01.dd,p11.dd,"-")
    p10.dd <- listOps((1-2*u1)*u1*(1-u1),xxt11,"*")
    p10.dd <- lapply(p10.dd,function(x){rbind(cbind(x,matrix(0,p1+1,p2+2)),matrix(0,p2+2,p1+p2+3))})
    p10.dd <- listOps(p10.dd,p11.dd,"-")
    p00.dd <- mapply(function(x,y,z){-x-y-z},p10.dd,p01.dd,p11.dd,SIMPLIFY = FALSE)
  }
  if(dim == p1+p2+2){
    p11.dd <- mapply(function(d11,d12,d22){rbind(cbind(d11,d12),cbind(t(d12),d22))},d11,d12,d22,SIMPLIFY = FALSE)
    p01.dd <- listOps((1-2*u2)*u2*(1-u2),xxt22,"*")
    p01.dd <- lapply(p01.dd,function(x){rbind(matrix(0,p1+1,p1+p2+2),cbind(matrix(0,p2+1,p1+1),x))})
    p01.dd <- listOps(p01.dd,p11.dd,"-")
    p10.dd <- listOps((1-2*u1)*u1*(1-u1),xxt11,"*")
    p10.dd <- lapply(p10.dd,function(x){rbind(cbind(x,matrix(0,p1+1,p2+1)),matrix(0,p2+1,p1+p2+2))})
    p10.dd <- listOps(p10.dd,p11.dd,"-")
    p00.dd <- mapply(function(x,y,z){-x-y-z},p10.dd,p01.dd,p11.dd,SIMPLIFY = FALSE)
  }
  return(list(p00.dd=p00.dd,p10.dd=p10.dd,p01.dd=p01.dd,p11.dd=p11.dd))
}