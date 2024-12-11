#include<stdio.h>
#include<stdlib.h>
#include<time.h>

typedef struct AVL {
	int value;
	int eq;
	struct AVL* fg;
	struct AVL* fd;
}AVL;

int min2(int a, int b){
	return a<b ? a : b;
}

int max2(int a, int b){
	return a>b ? a : b;
}

int max3(int a, int b, int c){
	return max2(max2(a,b), max2(b,c));
}

int min3(int a, int b, int c){
	return min2(min2(a,b), min2(b,c));
}

AVL* rotationLeft(AVL* a){
    AVL* pivot = a->fd; 
    int eq_a = a->eq, eq_p = pivot->eq;

    a->fd = pivot->fg; 
    pivot->fg = a;     

   
    a->eq = eq_a - max(eq_p, 0) - 1;
    pivot->eq = min3(eq_a - 2, eq_a + eq_p - 2, eq_p - 1);

    return pivot; 
}


	
struct AVL* rotationRight(AVL* a){
	AVL* pivot = a->fg;
	int eq_a= a->eq, eq_p= pivot->eq;
	
	a->fg = pivot->fd;
	pivot->fd= a;
	
	a->eq= eq_a - min2(eq_p,0) +1;
	pivot->eq= max3(eq_a +2, eq_a + eq_p +2, eq_a +1)
	return pivot;	
}
	
AVL* DoubleRotation_Left(AVL* arbre){
	arbre->fd = rotationRight(arbre->fd);
	return rotationLeft(arbre);
}

AVL* DoubleRotation_Right(AVL* arbre){
	arbre->fg = rotationLeft(arbre->fg);
	return rotationRight(arbre);
}

AVL* Equilibre(AVL* arbre){
	if(arbre->equilibre >=2){
		if(arbre->fd->eq >=0){
			return rotationLeft(arbre);
		}
		else {
			return DoubleRotation_Left(arbre);
		}
	else if(arbre->eq <= -2){
		if(arbre->fg->eq <=0){
			return rotationRight(arbre);
		}
		else {
			return DoubleRotation_Right(arbre);
		}
	}
	
	return arbre;
}

AVL* insertionAVL(AVL* a, int e, int *h){
	if(a == NULL){
		*h1 = 1;
		return creerAVL(e);
	}
	else if(e < a->valeur){
		a->fg = insertionAVL(a->fg, e, h);
		*h= -*h;
		}
	else if(e > a->valeur){
		a->fd = insertionAVL(a->fd, e, h);
	}
	
	else {
		*h=0;
		return a;
	}
	
	if(*h !=0){
		a->equilibre += *h;
		a = Equilibre(a);
		*h = (a->equilibre == 0) ? 0 : 1;
	}
	
	return a;
}		
		
AVL* suppminAVL(AVL* a, int *h, int *pe){
	AVL* temp;
	if(a->fg == NULL){
		*pe = a->valeur;
		*h = -1;
		temp = a;
		a = a->fd;
		free(temp);
		return a;
	}

	else {
		a->fg = suppMInAVL(a->fg, h, pe);
		*h = -*h;
	}
	
	if(*h != 0){
		a->eq += *h;
		a = Equilibre(a);
		*h = (a->eq == 0) ? -1 : 0;
	}
	return a;
}

AVL* suppressionAVL(AVL* a, int e, int *h)
{
    AVL* temp;
    if (a == NULL)
    { 
        *h = 0; 
        return a;
    }
    if (e > a->value)
    { 
        a->fd = suppressionAVL(a->fd, e, h);
    }
    else if (e < a->value)
    { 
        a->fg = suppressionAVL(a->fg, e, h);
        *h = -*h;
    }
    else if (a->fd != NULL)
    {
        a->fd = suppMinAVL(a->fd, h, &(a->value));
    }
    else
    {
        temp = a;
        a = a->fg;
        free(temp);
        *h = -1;
        return a;
    }
    if (a==NULL)
    {
        return a;
    }
    
    if (*h != 0)
    {
        a->eq += *h;
        a = equilibrerAVL(a);
        *h = (a->eq == 0) ? -1 : 0;
    }
    return a;
}

